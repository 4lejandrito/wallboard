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
    
    it "saves config while triggering setConfig" do
        @unit.config = {'key1'=>'value1','key2'=>'value2'}
        expect(@unit.config['key1']).to eq('value1')
        expect(@unit.config['key2']).to eq('value2')
        expect(@unit.config['key3']).to eq(nil)
    end
end