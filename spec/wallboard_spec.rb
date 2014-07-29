ENV['RACK_ENV'] = 'test'

require_relative '../wallboard.rb'
require 'rspec'
require 'rack/test'

describe "Wallboard" do
    include Rack::Test::Methods
    
    def app
        Wallboard::API
    end
    
    before do        
        app.set :plugins_folder, 'spec/plugins'
        app.set :pm, double(:available => [{"name" => 'builds'}, {"name" => 'heroes'}], :enabled => [{"name" => "builds", "config" => {}}])
    end    
    
    it "should return the main page" do       
        get '/'        
        expect(last_response.headers['Content-Type']).to eq('text/html;charset=utf-8')       
        expect(last_response.body).to include('<title>Wallboard</title>')        
    end
    
    it "should return the plugin assets page" do       
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
        expect(plugins["available"]).to eq([{"name" => 'builds'}, {"name" => 'heroes'}])
        expect(plugins["enabled"]).to eq([{"name" => 'builds', "config" => {}}])
    end
end

describe "PluginManager" do
    def app
        Wallboard::PluginManager.new('spec/plugins')
    end
    
    it "should return the plugins in the folder" do               
        expect(app.available).to eq([{:name => 'builds'}, {:name => 'heroes'}])        
    end
end