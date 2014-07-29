require 'sinatra/base'
require 'sinatra/json'
require 'sinatra-websocket'
require 'pathname'

module Wallboard    

    class Plugin
        
        def initialize
            @config = {}
            @w = 10
            @h = 6
        end
        
        def to_json(*a)
            {        
                "name" => "builds",
                "w" => @w,
                "h" => @h,
                "config" => @config
            }
        end        
    end
    
    class PluginManager
        def initialize(folder)
            @folder = folder
            Dir.glob(folder + "/*/plugin.rb").each{|f| require_relative f}            
        end
        
        def available
            Dir.glob(@folder + '/*').map { |f| {:name => Pathname.new(f).basename.to_s}}                
        end
        
        def enabled
            [Object.const_get('Builds')::Main.new()]            
        end
    end
                    
    class API < Sinatra::Base         
        configure do                          
            set :plugins_folder, 'plugins'
            set :pm, PluginManager.new(settings.plugins_folder)
        end        
        
        get '/' do
            send_file File.join(settings.public_folder, 'index.html')
        end
        
        get "/plugins" do
            json({
                :available => settings.pm.available,
                :enabled => settings.pm.enabled.map { |p| p.to_json}
            })
        end        
        
        get "/:plugin/public/:file" do
            send_file File.join(settings.plugins_folder, params[:plugin], 'public', params[:file])
        end
        
        get "/:plugin" do
            plugin = Object.const_get(params[:plugin].capitalize())::Main.new();

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