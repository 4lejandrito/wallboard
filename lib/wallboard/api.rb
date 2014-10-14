require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/activerecord'
require 'sinatra/assetpack'
require 'wallboard/pluginmanager'
require 'wallboard/wshandler'

module Wallboard
    class API < Sinatra::Base
        configure do
            set :plugins_folder, File.join(File.dirname(__FILE__), 'plugins')
            set :pm, PluginManager.new(settings.plugins_folder)
            set :ws, Wallboard::WSHandler.new(settings.pm)
        end

        register Sinatra::AssetPack

        assets do
            serve '/plugins', :from => 'plugins'
            serve '/public', :from => 'public'

            js :plugins, [
                '/plugins/*/public/plugin.js'
            ]
            css :plugins, [
                '/plugins/*/public/styles.css'
            ]
            js :wallboard, [
                '/public/js/*.js'
            ]
            css :wallboard, [
                '/public/wb.css'
            ]
        end

        get '/' do
            settings.ws.handle(request) or erb File.read(File.join(settings.public_folder, 'index.html'))
        end

        get "/plugin" do
            json(settings.pm)
        end

        post "/plugin" do
            if plugin = settings.pm.create((JSON.parse request.body.read)['name']) then json(plugin) else status 400 end
        end

        put "/plugin" do
            settings.pm.update(JSON.parse request.body.read)
            settings.pm
        end

        get "/:plugin/public/:file" do
            send_file File.join(settings.plugins_folder, params[:plugin], 'public', params[:file])
        end

        post "/plugin/:id/config" do
            plugin = settings.pm.get(params[:id]);
            if plugin then json(plugin.config = (JSON.parse request.body.read)) else status 404 end
        end

        post "/plugin/:id" do
            plugin = settings.pm.get(params[:id]);
            if plugin then json(plugin.message(JSON.parse request.body.read)) else status 404 end
        end

        delete "/plugin/:id" do
            if plugin = settings.pm.delete(params[:id]) then json(plugin) else status 404 end
        end

        get "/plugin/:id" do
            plugin = settings.pm.get(params[:id]);
            json plugin.get()
        end
    end
end
