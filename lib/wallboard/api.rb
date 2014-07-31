require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/activerecord'
require 'sinatra-websocket'
require 'wallboard/pluginmanager'

module Wallboard                
    class API < Sinatra::Base   
        configure do             
            set :plugins_folder, File.join(File.dirname(__FILE__), 'plugins')
            set :pm, PluginManager.new(settings.plugins_folder)
        end        
        
        get '/' do
            erb File.read(File.join(settings.public_folder, 'index.html'))
        end
        
        get "/plugins" do
            json(settings.pm)
        end    
        
        post "/plugins" do
            if plugin = settings.pm.create(params[:name]) then json(plugin) else status 400 end
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