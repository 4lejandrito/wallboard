ENV['RACK_ENV'] = 'test'

require 'wallboard/plugin'
require 'rspec'
require 'rufus-scheduler'

describe Wallboard::Plugin do

    before do
        @unit = Wallboard::Plugin.new(id: 'id-123', name: 'name-123')
    end

    it 'is initialized by id and name' do
        expect(@unit.id).to eq('id-123')
        expect(@unit.name).to eq('name-123')
    end

    it "stores the config as a map" do
        expect(@unit).to receive(:save).and_return(true)
        @unit.config = {'key1'=>'value1','key2'=>'value2'}
        expect(@unit.config['key1']).to eq('value1')
        expect(@unit.config['key2']).to eq('value2')
        expect(@unit.config['key3']).to eq(nil)
    end

    it "stores the layout as a map" do
        expect(@unit).to receive(:save).and_return(true)
        @unit.layout = {'x' => 0, 'y' => 0, 'w' => 0, 'h' => 0}
        expect(@unit.layout['x']).to eq(0)
        expect(@unit.layout['y']).to eq(0)
        expect(@unit.layout['w']).to eq(0)
        expect(@unit.layout['h']).to eq(0)
    end

    it "has a default get method" do
        expect(@unit.get()).to eq({})
    end

    it "can publish asynchronous messages" do
        expect(mock = double()).to receive(:callback).with('A message!!')
        @unit.on :message do |msg|
            mock.callback(msg)
        end
        @unit.publish('A message!!')
    end

    it "has a default message method" do
        mock = double()
        expect(@unit).to receive(:publish).with(mock).and_return(mock)
        expect(@unit.message(mock)).to eq(mock)
    end

    it "saves by default the last message received and returns it in get" do
        mock = double()
        @unit.message(mock)
        expect(@unit.get()).to eq(mock)
    end

    it 'can schedule jobs at startup' do
        expect(mock = double()).to receive(:callback).with(Rufus::Scheduler.singleton)

        class TestPlugin < Wallboard::Plugin
            def schedule(scheduler)
                @mock.callback(scheduler)
            end
        end

        TestPlugin.new(id: 'id-123', name: 'name-123', mock: mock)
    end

    it 'can be serialized to json' do
        @unit.config = {'key1'=>'value1','key2'=>'value2'}
        @unit.layout = {'x' => 0, 'y' => 0, 'w' => 0, 'h' => 0}
        expect(@unit.to_json).to eq("{\"_type\":\"Wallboard::Plugin\",\"config\":{\"key1\":\"value1\",\"key2\":\"value2\"},\"id\":\"id-123\",\"layout\":{\"x\":0,\"y\":0,\"w\":0,\"h\":0},\"name\":\"name-123\"}")
    end

    describe "Persistence" do

        before do
            Wallboard::Plugin.destroy_all
        end

        it "creates plugins in the database" do
            plugin = Wallboard::Plugin.create(id: 'id-123', name: 'name-123')
            expect(Wallboard::Plugin.first(:id => plugin.id)).to eq(plugin)
        end

        it "saves plugins in the database" do
            plugin = Wallboard::Plugin.new(id: 'id-123', name: 'name-123')
            plugin.save!
            expect(Wallboard::Plugin.first(:id => plugin.id)).to eq(plugin)
        end

        it "saves subclasses of plugin in the database" do
            class Subclass < Wallboard::Plugin
            end

            plugin = Subclass.create(id: 'id-1', name: 'name-1')

            dbPlugin = Wallboard::Plugin.first(:id => plugin.id)

            expect(dbPlugin).to be_kind_of(Subclass)
            expect(dbPlugin).to eq(plugin)
        end

        it "retrieves all the plugins from the database" do
            plugin1 = Wallboard::Plugin.create(id: 'id-1', name: 'name-1')
            plugin2 = Wallboard::Plugin.create(id: 'id-2', name: 'name-2')
            plugin3 = Wallboard::Plugin.create(id: 'id-3', name: 'name-3')

            expect(Wallboard::Plugin.all).to include(plugin1, plugin2, plugin3)
        end

        it "deletes a plugin from the database" do
            plugin1 = Wallboard::Plugin.create(id: 'id-1', name: 'name-1')
            plugin2 = Wallboard::Plugin.create(id: 'id-2', name: 'name-2')
            plugin3 = Wallboard::Plugin.create(id: 'id-3', name: 'name-3')

            plugin2.delete

            expect(Wallboard::Plugin.all).to include(plugin1, plugin3)
            expect(Wallboard::Plugin.all).to_not include(plugin2)
        end
    end
end
