ENV['RACK_ENV'] = 'test'

require_relative '../wallboard.rb'
require 'rspec'
require 'rack/test'

describe Wallboard::API do
    include Rack::Test::Methods
    
    def app
        Wallboard::API
    end
    
    before do        
        app.set :plugins_folder, 'spec/plugins'        
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
        get '/plugins'
        expect(last_response.headers['Content-Type']).to eq('application/json')       
        plugins = JSON.parse(last_response.body)        
        expect(plugins["available"]).to include({"name"=>"builds", "class"=>"Builds::Main"})
        expect(plugins["available"]).to include({"name"=>"heroes", "class"=>"Wallboard::Plugin"})
        expect(plugins["enabled"]).to eq([{"name" => 'builds', "config" => {}, "w" => 10, "h" => 6}])
    end
end

describe Wallboard::PluginManager do
    
    before do
        @pm = Wallboard::PluginManager.new('spec/plugins')
    end
    
    it "should return the plugins in the folder" do               
        expect(@pm.available).to include({:name => 'builds', :class => 'Builds::Main'})
        expect(@pm.available).to include({:name => 'heroes', :class => 'Wallboard::Plugin'})        
    end
    
    it "should create an instance of an available plugin" do
        expect(@pm.enabled).to eq([])                  
        @pm.create 'builds'                    
        expect(@pm.enabled.length).to eq(1)            
        expect(@pm.enabled[0]).to be_instance_of(Builds::Main)        
        expect(@pm.enabled[0].name).to eq('builds')        
    end
    
    it "should get a plugin by name" do
        expect(@pm.enabled).to eq([])                  
        @pm.create 'builds'                    
        expect(@pm.get('builds')).to be_instance_of(Builds::Main)        
        expect(@pm.enabled[0].name).to eq('builds')        
    end
end