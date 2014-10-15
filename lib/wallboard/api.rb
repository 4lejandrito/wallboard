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
            json settings.pm
        end

        post "/plugin" do
            json settings.pm.create((JSON.parse request.body.read)['name'])
        end

        put "/plugin" do
            json settings.pm.update(JSON.parse request.body.read)
        end

        get "/:plugin/public/:file" do
            send_file File.join(settings.plugins_folder, params[:plugin], 'public', params[:file])
        end

        get "/plugin/:id" do
            json settings.pm.get(params[:id]).get();
        end

        post "/plugin/:id" do
            json settings.pm.get(params[:id]).message(JSON.parse request.body.read)
        end

        delete "/plugin/:id" do
            json settings.pm.delete(params[:id])
        end

        post "/plugin/:id/config" do
            json settings.pm.get(params[:id]).config = (JSON.parse request.body.read)
        end

        error do |error|
            status 400
            error.message
        end
    end
end
