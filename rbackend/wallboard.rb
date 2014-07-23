require 'sinatra/base'
require 'sinatra/json'
require 'sinatra-websocket'
require 'sinatra/cross_origin'

module Wallboard    

    class API < Sinatra::Base
        register Sinatra::CrossOrigin
        
        configure do
            enable :cross_origin            
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
    
    class Plugin      
    end
    
    Dir.glob("plugins/**/*.rb").each{|f| require_relative f}
    
end