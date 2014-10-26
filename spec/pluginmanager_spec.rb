require 'wallboard/pluginmanager'
require 'wallboard/plugin'
require 'rspec'

describe Wallboard::PluginManager do

    before do
        allow_any_instance_of(Wallboard::Plugin).to receive(:save).and_return(true)
        allow(Wallboard::Plugin).to receive(:all).and_return(enabledPlugins = [])
        @pm = Wallboard::PluginManager.new(File.join(Dir.pwd, 'spec/plugins'))
    end

    it "returns the plugins in the folder" do
        expect(@pm.available).to include({:name => 'plugin1', :class => 'Plugin1::Main'})
        expect(@pm.available).to include({:name => 'plugin2', :class => 'Wallboard::Plugin'})
    end

    it "loads the enabled plugins only the first time" do
        expect(Wallboard::Plugin).to receive(:all).and_return(enabledPlugins = [])

        expect(@pm.enabled).to be(enabledPlugins)
        expect(@pm.enabled).to be(enabledPlugins)
    end

    it "creates an instance of an available plugin and save it" do
        expect_any_instance_of(Wallboard::Plugin).to receive(:save).and_return(true)
        expect(@pm.enabled).to eq([])
        plugin = @pm.create 'plugin1'
        expect(plugin).to be_instance_of(Plugin1::Main)
        expect(plugin.name).to eq('plugin1')
        expect(@pm.enabled.length).to eq(1)
        expect(@pm.enabled[0]).to be(plugin)
    end

    it "gets a plugin by id" do
        expect(@pm.enabled).to eq([])
        plugin = @pm.create 'plugin1'
        expect(@pm.get(plugin.id)).to be(plugin)
    end

    it "gets a plugin by name" do
        expect(@pm.enabled).to eq([])
        plugin = @pm.create 'plugin1'
        expect(@pm.get('plugin1')).to be(plugin)
    end

    it "raises an error if a plugin does not exist" do
        expect{ @pm.create('whatever') }.to raise_error
        expect{ @pm.get('plugin1') }.to raise_error
        expect{ @pm.delete('plugin1') }.to raise_error
    end

    it "can remove an enabled plugin by id and return it" do
        expect(@pm.enabled).to eq([])
        plugin = @pm.create 'plugin1'
        expect(plugin).to receive(:delete).and_return(true)
        deletedPlugin = @pm.delete plugin.id
        expect(@pm.enabled.length).to eq(0)
        expect(deletedPlugin).to eq(plugin)
    end

    it "can update an array of plugins" do
      plugin1 = @pm.create 'plugin1'
      plugin2 = @pm.create 'plugin2'

      @pm.update [
          {'id' => plugin1.id, 'layout' => {'x'=>0, 'y' => 0, 'w' => 10, 'h' => 10}},
          {'id' => plugin2.id, 'layout' => {'x'=>10, 'y' => 10, 'w' => 0, 'h' => 0}}
      ]
      expect(@pm.enabled[0].layout).to eq({'x'=>0, 'y' => 0, 'w' => 10, 'h' => 10})
      expect(@pm.enabled[1].layout).to eq({'x'=>10, 'y' => 10, 'w' => 0, 'h' => 0})
    end

    it "broadcasts itself after creating, deleting and updating" do
      mock = double()
      @pm.on :message do |msg|
        mock.callback(msg)
      end

      expect(mock).to receive(:callback).with(@pm)
      plugin1 = @pm.create 'plugin1'

      expect(mock).to receive(:callback).with(@pm)
      plugin2 = @pm.create 'plugin2'

      expect(mock).to receive(:callback).with(@pm)
      @pm.update [
          {'id' => plugin1.id, 'layout' => {'x'=>0, 'y' => 0, 'w' => 10, 'h' => 10}},
          {'id' => plugin2.id, 'layout' => {'x'=>10, 'y' => 10, 'w' => 0, 'h' => 0}}
      ]

      expect(mock).to receive(:callback).with(@pm)
      @pm.delete(plugin1.id);
    end

    it "broadcasts plugin messages" do
        expect(Wallboard::Plugin).to receive(:all).and_return([plugin1 = Wallboard::Plugin.new(id: 'plugin1')])

        plugin2 = @pm.create 'plugin2'

        expect(mock = double()).to receive(:callback).with({:plugin => plugin1.id, :data => 'something1'})
        expect(mock).to receive(:callback).with({:plugin => plugin2.id, :data => 'something2'})

        @pm.on :message do |msg|
            mock.callback(msg)
        end

        plugin1.publish('something1')
        plugin2.publish('something2')
    end
end
