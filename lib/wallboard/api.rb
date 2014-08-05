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
        
        get "/plugin" do
            json({:enabled => settings.pm.enabled, :available => settings.pm.available})
        end    
        
        post "/plugin" do
            if plugin = settings.pm.create(params[:name]) then json(plugin) else status 400 end
        end
        
        get "/:plugin/public/:file" do
            send_file File.join(settings.plugins_folder, params[:plugin], 'public', params[:file])
        end
        
        post "/plugin/:id/config" do
            plugin = settings.pm.get(params[:id]);
            plugin.config = JSON.parse request.body.read
        end
        
        delete "/plugin/:id" do
            if plugin = settings.pm.delete(params[:id]) then json(plugin) else status 404 end            
        end
        
        get "/plugin/:id" do
            plugin = settings.pm.get(params[:id]);

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