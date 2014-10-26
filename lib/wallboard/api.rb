require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/assetpack'
require 'wallboard/pluginmanager'
require 'wallboard/wshandler'
require 'sinatra/namespace'
require 'less';

module Wallboard
    class API < Sinatra::Base
        configure do
            set :plugins_folder, File.join(File.dirname(__FILE__), 'plugins')
            set :pm, PluginManager.new(settings.plugins_folder)
            set :ws, Wallboard::WSHandler.new(settings.pm)
        end

        register Sinatra::AssetPack
        register Sinatra::Namespace

        pm = settings.pm

        namespace "/assets" do
            assets do
                Less.paths << File.join(File.dirname(__FILE__), '/public/css')

                serve '/assets/plugins', :from => 'plugins'
                serve '/assets/wallboard', :from => 'public'

                js :wallboard, [
                    '/assets/wallboard/js/*.js'
                ]
                css :wallboard, [
                    '/assets/wallboard/css/wb.css'
                ]

                pm.available.each do |p|
                    js p[:name].to_sym, [
                        "/assets/plugins/#{p[:name]}/public/*.js"
                    ]
                    css p[:name].to_sym, [
                        '/assets/wallboard/css/plugin.css',
                        "/assets/plugins/#{p[:name]}/public/*.css"
                    ]
                end
            end

            get "/plugins/:plugin/:file" do
                send_file File.join(settings.plugins_folder, params[:plugin], 'public', params[:file])
            end
        end


        get "/" do
            erb :index
        end

        get "/plugin/:id" do
            erb :plugin, :locals => {:plugin => settings.pm.get(params[:id])}
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
                    json settings.pm.create(params[:name])
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
