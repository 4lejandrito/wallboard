require 'wallboard/wshandler'
require 'wallboard/pluginmanager'
require 'wallboard/plugin'
require 'faye/websocket'
require 'rspec'

describe Wallboard::WSHandler do

    class MockWS < Faye::WebSocket
        attr_accessor :driver
    end

    before do
        @pm = Wallboard::PluginManager.new(File.join(Dir.pwd, 'spec/plugins'))
        @plugin = @pm.create 'plugin1'
        @unit = Wallboard::WSHandler.new(@pm)
        @request = double(:env => {})
        allow(Faye::WebSocket).to receive(:websocket?).and_return(true)
    end

    it "returns the websocket rack_response" do
        expect(Faye::WebSocket).to receive(:new).and_return(ws = MockWS.new({}))
        expect(@unit.handle(@request)).to eq(ws.rack_response)
    end

    it "returns nil when the request is not a websocket" do
        allow(Faye::WebSocket).to receive(:websocket?).and_return(false)
        expect(@unit.handle(@request)).to eq(nil)
    end

    it "calls plugin message on websocket message parsing the json" do
        expect(Faye::WebSocket).to receive(:new).and_return(ws = MockWS.new({}))

        @unit.handle(@request)
        sleep 0.5

        expect(@plugin).to receive(:message).with({'key' => 'value'})

        ws.driver.emit(:message, double(:data => '{"plugin": "plugin1", "data": {"key": "value"}}'))
    end

    it "broadcasts the message triggered by the plugin through the websocket in json" do
        allow(Faye::WebSocket).to receive(:new).and_return(wsA = MockWS.new({}), wsB = MockWS.new({}))

        @unit.handle(@request)
        @unit.handle(@request)
        sleep 0.5

        expect(wsA).to receive(:send).with({:plugin => @plugin.id, :data => {:key => "value"}}.to_json)
        expect(wsB).to receive(:send).with({:plugin => @plugin.id, :data => {:key => "value"}}.to_json)

        @plugin.send({:key => 'value'})
    end
end
