ENV['RACK_ENV'] = 'test'

require 'sinatra/respond_with'
require 'wallboard/api'
require 'wallboard/pluginmanager'
require 'rspec'
require 'rack/test'

describe Wallboard::API do
    include Rack::Test::Methods
    
    def app
        Wallboard::API
    end
    
    before do        
        app.set :plugins_folder, File.join(Dir.pwd, 'spec/plugins')
        app.set :pm, Wallboard::PluginManager.new(app.settings.plugins_folder)
    end    
    
    it "should return the main page" do       
        get '/'        
        expect(last_response.headers['Content-Type']).to eq('text/html;charset=utf-8')       
        expect(last_response.body).to include('<title>Wallboard</title>')        
    end
    
    it "should return the plugin assets" do       
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
    
    it "should return the plugins" do       
        get '/plugins'
        expect(last_response.headers['Content-Type']).to eq('application/json')       
        plugins = JSON.parse(last_response.body)        
        expect(plugins["available"]).to include({"name"=>"builds", "class"=>"Builds::Main"})
        expect(plugins["available"]).to include({"name"=>"heroes", "class"=>"Wallboard::Plugin"})
        expect(plugins["enabled"]).to eq([])
    end
    
    it "should create plugins" do       
        post '/plugins', :name => 'builds'
        expect(JSON.parse(last_response.body)).to eq({"name" => 'builds', "config" => {}, "w" => 10, "h" => 6})
        get '/plugins'
        expect(last_response.headers['Content-Type']).to eq('application/json')       
        plugins = JSON.parse(last_response.body)        
        expect(plugins["available"]).to include({"name"=>"builds", "class"=>"Builds::Main"})
        expect(plugins["available"]).to include({"name"=>"heroes", "class"=>"Wallboard::Plugin"})
        expect(plugins["enabled"]).to eq([{"name" => 'builds', "config" => {}, "w" => 10, "h" => 6}])
    end
    
    it "should return an error if we try to create a non available plugin" do       
        post '/plugins', :name => 'idontexist'
        expect(last_response.status).to eq(400)
        get '/plugins'
        expect(last_response.headers['Content-Type']).to eq('application/json')       
        plugins = JSON.parse(last_response.body)        
        expect(plugins["available"]).to include({"name"=>"builds", "class"=>"Builds::Main"})
        expect(plugins["available"]).to include({"name"=>"heroes", "class"=>"Wallboard::Plugin"})
        expect(plugins["enabled"]).to eq([])
    end
end