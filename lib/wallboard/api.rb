require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/activerecord'
require 'sinatra/assetpack'
require 'sinatra-websocket'
require 'wallboard/pluginmanager'

module Wallboard                
    class API < Sinatra::Base   
        configure do             
            set :plugins_folder, File.join(File.dirname(__FILE__), 'plugins')
            set :pm, PluginManager.new(settings.plugins_folder)
        end        
        
        register Sinatra::AssetPack

        assets do
            serve '/plugins', :from => 'plugins'
            serve '/public', :from => 'public'   
                
            js :plugins, [
                '/plugins/*/public/widget.js'
            ]
            css :plugins, [
                '/plugins/*/public/styles.css'
            ]
            css :wallboard, [
                '/public/wb.css'
            ]
        end

        get '/' do
            erb File.read(File.join(settings.public_folder, 'index.html'))
        end
        
        get "/plugin" do
            json({:enabled => settings.pm.enabled, :available => settings.pm.available})
        end    
        
        post "/plugin" do
            if plugin = settings.pm.create((JSON.parse request.body.read)['name']) then json(plugin) else status 400 end
        end
        
        get "/:plugin/public/:file" do
            send_file File.join(settings.plugins_folder, params[:plugin], 'public', params[:file])
        end
        
        post "/plugin/:id/config" do
            plugin = settings.pm.get(params[:id]);
            if plugin then json(plugin.config = (JSON.parse request.body.read)) else status 404 end
        end
        
        post "/plugin/:id/layout" do
            plugin = settings.pm.get(params[:id]);
            if plugin then json(plugin.layout = (JSON.parse request.body.read)) else status 404 end
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