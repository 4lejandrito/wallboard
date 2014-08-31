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
        app.set :pm, double(
            :enabled => [Wallboard::Plugin.new('some_uuid', 'test-plugin')],
            :available => [{"name"=>"builds", "class"=>"Builds::Main"}, {"name"=>"heroes", "class"=>"Wallboard::Plugin"}]
        )
    end
    
    describe "GET /" do
        it "returns the main page" do       
            get '/'        
            expect(last_response.headers['Content-Type']).to eq('text/html;charset=utf-8')       
            expect(last_response.body).to include('<title>Wallboard</title>')        
        end
    end
    
    describe "GET /:plugin/public/:asset" do
        it "returns the plugin assets" do       
            get '/builds/public/index.html'
            expect(last_response.headers['Content-Type']).to eq('text/html;charset=utf-8')
            expect(last_response.body).to eq('this is html')
            get '/builds/public/styles.css'
            expect(last_response.headers['Content-Type']).to eq('text/css;charset=utf-8')       
            expect(last_response.body).to eq('this is css')        
            get '/builds/public/widget.js'        
            expect(last_response.headers['Content-Type']).to eq('application/javascript;charset=utf-8')       
            expect(last_response.body).to eq('this is js')        
        end
    end
    
    describe "GET /plugin" do
        it "returns the plugins" do 
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
            post '/plugin', :name => 'whatever'
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
            post '/plugin', :name => 'whatever'
            expect(last_response.status).to eq(400)
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
    
    describe "POST /plugin/:id/layout" do
       it 'stores layout into the plugin' do
           plu = Wallboard::Plugin.new('some_uuid', 'test-plugin')
           expect(app.settings.pm).to receive(:get).with("some_uuid").and_return(plu)
           post '/plugin/some_uuid/layout', {'x'=>0, 'y' => 0, 'w' => 10, 'h' => 10}.to_json, { 'CONTENT_TYPE' => 'application/json'}
           expect(plu.layout['x']).to eq(0)
           expect(plu.layout['y']).to eq(0)
           expect(plu.layout['w']).to eq(10)
           expect(plu.layout['h']).to eq(10)
           expect(last_response.body).to eq(plu.layout.to_json)
        end
        
        it "returns an error if we try to modify a non enabled plugin" do       
            expect(app.settings.pm).to receive(:get).with("whatever").and_return(nil)
            post '/plugin/whatever/layout', {'x'=>0, 'y' => 0, 'w' => 10, 'h' => 10}.to_json, { 'CONTENT_TYPE' => 'application/json'}
            expect(last_response.status).to eq(404)
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