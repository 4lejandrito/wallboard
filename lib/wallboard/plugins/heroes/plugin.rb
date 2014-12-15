require 'wallboard/plugin'
require 'rest_client'
require 'json'

module Heroes
    class Main < Wallboard::Plugin
        def get
            JSON.parse(
                RestClient.get 'http://ukdevstage01:9000/developer/highscore'
            ).map do |hero|
                {
                    :name => "#{hero['firstname']} #{hero['lastname']}",
                    :email => hero['email'],
                    :commits => hero['commitCount']
                }
            end
        end
    end
end
