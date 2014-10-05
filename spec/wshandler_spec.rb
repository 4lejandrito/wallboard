require 'wallboard/wshandler'
require 'wallboard/plugin'
require 'em-websocket'
require 'rspec'

describe Wallboard::WSHandler do

    before do
        @ws = EventMachine::WebSocket::Connection.new({}, {})
        @plugin = Wallboard::Plugin.new('some_id', 'some_name')
        @unit = Wallboard::WSHandler.new(@plugin, @ws)
    end

    it "calls plugin get on websocket open and send the result back" do
        expect(@plugin).to receive(:get).and_return({:key => 'value'})
        expect(@ws).to receive(:send).with('{"key":"value"}')
        @ws.trigger_on_open();
    end

    it "calls plugin message on websocket message parsing the json" do
        expect(@plugin).to receive(:message).with({'key' => 'value'})
        @ws.trigger_on_message('{"key":"value"}');
    end

    it "sends the message triggered by the plugin through the websocket in json" do
        expect(@ws).to receive(:send).with('{"key":"value"}')
        @plugin.message({:key => 'value'})
    end
end
