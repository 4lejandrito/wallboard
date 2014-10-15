require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/activerecord'
require 'sinatra/assetpack'
require 'wallboard/pluginmanager'
require 'wallboard/wshandler'
require "sinatra/namespace"

module Wallboard
    class API < Sinatra::Base
        configure do
            set :plugins_folder, File.join(File.dirname(__FILE__), 'plugins')
            set :pm, PluginManager.new(settings.plugins_folder)
            set :ws, Wallboard::WSHandler.new(settings.pm)
        end

        register Sinatra::AssetPack
        register Sinatra::Namespace

        namespace "/assets" do
            assets do
                serve '/assets/plugins', :from => 'plugins'
                serve '/assets/wallboard', :from => 'public'

                js :wallboard, [
                    '/assets/wallboard/js/*.js',
                    '/assets/plugins/*/public/plugin.js'
                ]
                css :wallboard, [
                    '/assets/wallboard/wb.css',
                    '/assets/plugins/*/public/styles.css'
                ]
            end

            get "/plugins/:plugin/:file" do
                send_file File.join(settings.plugins_folder, params[:plugin], 'public', params[:file])
            end
        end

        get "/" do
            erb File.read(File.join(settings.public_folder, 'index.html'))
        end

        namespace "/api" do

            get do
                settings.ws.handle(request)
            end

            namespace "/plugin" do

                get do
                    json settings.pm
                end

                post do
                    json settings.pm.create((JSON.parse request.body.read)['name'])
                end

                put do
                    json settings.pm.update(JSON.parse request.body.read)
                end

                get "/:id" do
                    json settings.pm.get(params[:id]).get();
                end

                post "/:id" do
                    json settings.pm.get(params[:id]).message(JSON.parse request.body.read)
                end

                delete "/:id" do
                    json settings.pm.delete(params[:id])
                end

                post "/:id/config" do
                    json settings.pm.get(params[:id]).config = (JSON.parse request.body.read)
                end
            end
        end

        error do |error|
            status 400
            error.message
        end
    end
end
