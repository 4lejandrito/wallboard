require 'wallboard/pluginmanager'
require 'rspec'

describe Wallboard::PluginManager do
    
    before do
        @pm = Wallboard::PluginManager.new(File.join(Dir.pwd, 'spec/plugins'))
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