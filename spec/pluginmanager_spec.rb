require 'wallboard/pluginmanager'
require 'rspec'

describe Wallboard::PluginManager do

    before do
        @pm = Wallboard::PluginManager.new(File.join(Dir.pwd, 'spec/plugins'))
    end

    it "returns the plugins in the folder" do
        expect(@pm.available).to include({:name => 'plugin1', :class => 'Plugin1::Main'})
        expect(@pm.available).to include({:name => 'plugin2', :class => 'Wallboard::Plugin'})
    end

    it "creates an instance of an available plugin" do
        expect(@pm.enabled).to eq([])
        plugin = @pm.create 'plugin1'
        expect(plugin).to be_instance_of(Plugin1::Main)
        expect(plugin.name).to eq('plugin1')
        expect(@pm.enabled.length).to eq(1)
        expect(@pm.enabled[0]).to be(plugin)
    end

    it "returns null if we try to create an unavailable plugin" do
        expect(@pm.enabled).to eq([])
        expect(@pm.create 'idontexist').to eq(nil)
        expect(@pm.enabled.length).to eq(0)
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

    it "can remove an enabled plugin by id and return it" do
        expect(@pm.enabled).to eq([])
        plugin = @pm.create 'plugin1'
        deletedPlugin = @pm.delete plugin.id
        expect(@pm.enabled.length).to eq(0)
        expect(deletedPlugin).to eq(plugin)
    end

    it "returns null if we try to remove an unexisting plugin" do
        expect(@pm.enabled).to eq([])
        deletedPlugin = @pm.delete "whatever"
        expect(@pm.enabled.length).to eq(0)
        expect(deletedPlugin).to eq(nil)
    end

    it "broadcasts plugin messages" do
        plugin = @pm.create 'plugin1'

        expect(mock = double()).to receive(:callback).with({:plugin => plugin.id, :data => 'something'})

        @pm.on :message do |msg|
            mock.callback(msg)
        end

        plugin.send('something')
    end
end
