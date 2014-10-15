ENV['RACK_ENV'] = 'test'

require 'sinatra/respond_with'
require 'wallboard/api'
require 'rspec'
require 'rack/test'

describe Wallboard::API do
    include Rack::Test::Methods

    def app
        Wallboard::API
    end

    before do
        app.set :plugins_folder, File.join(Dir.pwd, 'spec/plugins')
    end

    describe "GET /" do
        it "returns the main page" do
            get '/'
            expect(last_response.headers['Content-Type']).to eq('text/html;charset=utf-8')
            expect(last_response.body).to include('<title>Wallboard</title>')
        end

        it "process a potential websocket request" do
          allow(app.settings.ws).to receive(:handle).and_return('Something')
          get '/'
          expect(app.settings.ws).to have_received(:handle).with(kind_of(Rack::Request))
          expect(last_response.body).to eq('Something')
        end
    end

    describe "GET /:plugin/public/:asset" do
        it "returns the plugin assets" do
            get '/plugin1/public/index.html'
            expect(last_response.headers['Content-Type']).to eq('text/html;charset=utf-8')
            expect(last_response.body).to eq('this is html')
            get '/plugin1/public/styles.css'
            expect(last_response.headers['Content-Type']).to eq('text/css;charset=utf-8')
            expect(last_response.body).to eq('this is css')
            get '/plugin1/public/plugin.js'
            expect(last_response.headers['Content-Type']).to eq('application/javascript;charset=utf-8')
            expect(last_response.body).to eq('this is js')
        end
    end

    describe "GET /plugin" do
        it "returns the plugins" do
            app.settings.pm.enabled = [Wallboard::Plugin.new('some_uuid', 'test-plugin')]
            app.settings.pm.available = [
                {"name"=>"builds", "class"=>"Builds::Main"},
                {"name"=>"heroes", "class"=>"Wallboard::Plugin"}
            ]
            get '/plugin'
            expect(last_response.headers['Content-Type']).to eq('application/json')
            plugins = JSON.parse(last_response.body)
            expect(plugins["available"]).to include({"name"=>"builds", "class"=>"Builds::Main"})
            expect(plugins["available"]).to include({"name"=>"heroes", "class"=>"Wallboard::Plugin"})
            expect(plugins["enabled"]).to eq([{
                "id" => "some_uuid",
                "name" => 'test-plugin',
                "config" => {},
                "layout" => {}
            }])
        end
    end

    describe "POST /plugin" do
        it "creates plugins" do
            expect(app.settings.pm).to receive(:create).with("whatever").and_return(Wallboard::Plugin.new('some_uuid', 'test-plugin'))
            post '/plugin', {:name => 'whatever'}.to_json, { 'CONTENT_TYPE' => 'application/json'}
            expect(last_response.headers['Content-Type']).to eq('application/json')
            expect(last_response.body).to eq({
                "id" => "some_uuid",
                "name" => 'test-plugin',
                "config" => {},
                "layout" => {}
            }.to_json)
        end

        it "returns an error if we try to create a non available plugin" do
            expect(app.settings.pm).to receive(:create).with("whatever").and_return(nil)
            post '/plugin', {:name => 'whatever'}.to_json, { 'CONTENT_TYPE' => 'application/json'}
            expect(last_response.status).to eq(400)
        end
    end

    describe "PUT /plugin" do
      it 'updates the plugins' do
        expect(app.settings.pm).to receive(:update).with([{'id' => 'some_uuid', 'layout' => {'x' => 0, 'y' => 0, 'w' => 10, 'h' => 10}}])
        put '/plugin', [{:id => 'some_uuid', :layout => {'x' => 0, 'y' => 0, 'w' => 10, 'h' => 10}}].to_json, { 'CONTENT_TYPE' => 'application/json'}
      end
    end

    describe "POST /plugin/:id/config" do
       it 'stores config into the plugin' do
           plu = Wallboard::Plugin.new('some_uuid', 'test-plugin')
           expect(app.settings.pm).to receive(:get).with("some_uuid").and_return(plu)
           post '/plugin/some_uuid/config', {'key1'=>'value1', 'key2' => 'value2'}.to_json, { 'CONTENT_TYPE' => 'application/json'}
           expect(plu.config['key1']).to eq('value1')
           expect(plu.config['key2']).to eq('value2')
           expect(last_response.body).to eq(plu.config.to_json)
        end

        it "returns an error if we try to modify a non enabled plugin" do
            expect(app.settings.pm).to receive(:get).with("some_uuid").and_return(nil)
            post '/plugin/some_uuid/config', {'key1'=>'value1', 'key2' => 'value2'}.to_json, { 'CONTENT_TYPE' => 'application/json'}
            expect(last_response.status).to eq(404)
        end
    end

    describe "GET /plugin/:id" do
        it "returns the result of the plugin get method" do
            plu = Wallboard::Plugin.new('some_uuid', 'test-plugin')
            expect(app.settings.pm).to receive(:get).with("some_uuid").and_return(plu)
            expect(plu).to receive(:get).and_return({:key => 'value'})
            get '/plugin/some_uuid'
            expect(last_response.headers['Content-Type']).to eq('application/json')
            expect(last_response.body).to eq({
                "key" => "value"
            }.to_json)
        end

        it "returns an error if we try to get a non available plugin" do
            expect(app.settings.pm).to receive(:get).with("whatever").and_return(nil)
            get '/plugin/whatever'
            expect(last_response.status).to eq(404)
        end
    end

    describe "POST /plugin/:id" do
       it 'sends a message to the plugin' do
           plu = Wallboard::Plugin.new('some_uuid', 'test-plugin')
           expect(app.settings.pm).to receive(:get).with("some_uuid").and_return(plu)
           expect(plu).to receive(:message).with({'key'=> 'value'}).and_return({'key1'=> 'value1'})

           post '/plugin/some_uuid', {'key'=> 'value'}.to_json, { 'CONTENT_TYPE' => 'application/json'}

           expect(last_response.body).to eq({'key1'=> 'value1'}.to_json)
        end
    end

    describe "DELETE /plugin/:id" do
       it 'deletes an enabled plugin' do
           plu = Wallboard::Plugin.new('some_uuid', 'test-plugin')
           expect(app.settings.pm).to receive(:delete).with("some_uuid").and_return(plu)
           delete '/plugin/some_uuid'
        end
        it "returns an error if we try to delete a non enabled plugin" do
            expect(app.settings.pm).to receive(:delete).with("whatever").and_return(nil)
            delete '/plugin/whatever'
            expect(last_response.status).to eq(404)
        end
    end
end
