require 'wallboard/plugin'

module Message
    class Main < Wallboard::Plugin
        def get
            @message or {:message => ''}
        end

        def message(data)
            send(@message = data)
        end
    end
end
