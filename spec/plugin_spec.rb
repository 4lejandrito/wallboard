require 'wallboard/plugin'
require 'rspec'

describe Wallboard::Plugin do

    before do
        @unit = Wallboard::Plugin.new('id-123', 'name-123')
    end

    it 'is initialized by id and name' do
        expect(@unit.id).to eq('id-123')
        expect(@unit.name).to eq('name-123')
    end

    it "stores the config as a map" do
        @unit.config = {'key1'=>'value1','key2'=>'value2'}
        expect(@unit.config['key1']).to eq('value1')
        expect(@unit.config['key2']).to eq('value2')
        expect(@unit.config['key3']).to eq(nil)
    end

    it "stores the layout as a map" do
        @unit.layout = {'x' => 0, 'y' => 0, 'w' => 0, 'h' => 0}
        expect(@unit.layout['x']).to eq(0)
        expect(@unit.layout['y']).to eq(0)
        expect(@unit.layout['w']).to eq(0)
        expect(@unit.layout['h']).to eq(0)
    end

    it "has a default get method" do
        expect(@unit.get()).to eq({})
    end

    it "has a default message method" do
        mock = double()
        expect(@unit).to receive(:send).with(mock).and_return(mock)
        expect(@unit.message(mock)).to eq(mock)
    end

    it "can send asynchronous messages" do
        expect(mock = double()).to receive(:callback).with('A message!!')
        @unit.onmessage do |msg|
            mock.callback(msg)
        end
        @unit.send('A message!!')
    end
end
