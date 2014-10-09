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
        @ws = MockWS.new({})
        @pm = Wallboard::PluginManager.new(File.join(Dir.pwd, 'spec/plugins'))
        allow(@pm).to receive(:enabled).and_return([Wallboard::Plugin.new('some_uuid', 'test-plugin')])
        Wallboard::WSHandler.new(@pm, @ws).handle
    end

    it "calls plugin message on websocket message parsing the json" do
        expect(@pm.get('some_uuid')).to receive(:message).with({'key' => 'value'})
        @ws.driver.emit(:message, double(:data => '{"plugin": "some_uuid", "data": {"key": "value"}}'))
        sleep 0.2
    end

    it "sends the message triggered by the plugin through the websocket in json" do
        expect(@ws).to receive(:send).with('{"plugin":"some_uuid","data":{"key":"value"}}')
        @pm.get('some_uuid').send({:key => 'value'})
    end
end
