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
        @pm.create 'plugin1'
        @unit = Wallboard::WSHandler.new(@pm)
    end

    after do
        sleep 0.5
    end

    it "calls plugin message on websocket message parsing the json" do
        @unit.handle(ws = MockWS.new({}))

        expect(@pm.get('plugin1')).to receive(:message).with({'key' => 'value'})

        ws.driver.emit(:message, double(:data => '{"plugin": "plugin1", "data": {"key": "value"}}'))
    end

    it "broadcasts the message triggered by the plugin through the websocket in json" do
        @unit.handle(wsA = MockWS.new({}))
        @unit.handle(wsB = MockWS.new({}))

        expect(wsA).to receive(:send).with({:plugin => @pm.get('plugin1').id, :data => {:key => "value"}}.to_json)
        expect(wsB).to receive(:send).with({:plugin => @pm.get('plugin1').id, :data => {:key => "value"}}.to_json)

        @pm.get('plugin1').send({:key => 'value'})
    end
end
