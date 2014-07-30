require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/activerecord'
require 'sinatra-websocket'
require 'pathname'

module Wallboard    
        
    class Plugin
        attr_accessor :name
        
        def initialize(name)
            @name = name
            @config = {}
            @w = 10
            @h = 6
        end
    end
    
    class PluginManager
        attr_accessor :enabled, :available
        
        def initialize(folder)
            @folder = folder
            Dir.glob(folder + "/*/plugin.rb").each{|f| require_relative f}            
            self.available = Dir.glob(@folder + '/*').map do |f| 
                name = Pathname.new(f).basename.to_s
                clazz = Plugin.name
                begin  
                    clazz = Object.const_get(name.capitalize())::Main.name
                rescue NameError                
                end
                {:name => name, :class => clazz}
            end
            self.enabled = []            
        end
        
        def create(name)
            self.enabled << self.available.select { |p| p[:name] == name}[0][:class].split('::').inject(Object) {|o,c| o.const_get c}.new(name)        
        end
        
        def get(name)
            self.enabled.select { |p| p.name == name}[0]
        end
    end
                    
    class API < Sinatra::Base   
        configure do             
            set :plugins_folder, 'plugins'
            set :pm, PluginManager.new(settings.plugins_folder)
        end        
        
        get '/' do
            erb File.read(File.join(settings.public_folder, 'index.html'))
        end
        
        get "/plugins" do
            json({
                :available => settings.pm.available,
                :enabled => settings.pm.enabled
            })
        end    
        
        post "/plugins" do
            json settings.pm.create(params[:name])
        end    
        
        get "/:plugin/public/:file" do
            send_file File.join(settings.plugins_folder, params[:plugin], 'public', params[:file])
        end
        
        get "/:plugin" do
            plugin = settings.pm.get(params[:plugin]);

            if request.websocket?          
                request.websocket do |ws|
                    ws.onopen do
                        ws.send(json plugin.start())            
                    end
                    ws.onmessage do |msg|            
                        plugin.message(msg)
                    end
                    ws.onclose do
                        plugin.close();
                    end
                end
            else
                json plugin.get()
            end
        end
    end
end