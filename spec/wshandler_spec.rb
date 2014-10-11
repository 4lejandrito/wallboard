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
    end

    it "calls plugin message on websocket message parsing the json" do
        @unit.handle(ws = MockWS.new({}))
        sleep 0.5

        expect(@plugin).to receive(:message).with({'key' => 'value'})

        ws.driver.emit(:message, double(:data => '{"plugin": "plugin1", "data": {"key": "value"}}'))
    end

    it "broadcasts the message triggered by the plugin through the websocket in json" do
        @unit.handle(wsA = MockWS.new({}))
        @unit.handle(wsB = MockWS.new({}))
        sleep 0.5

        expect(wsA).to receive(:send).with({:plugin => @plugin.id, :data => {:key => "value"}}.to_json)
        expect(wsB).to receive(:send).with({:plugin => @plugin.id, :data => {:key => "value"}}.to_json)

        @plugin.send({:key => 'value'})
    end
end
