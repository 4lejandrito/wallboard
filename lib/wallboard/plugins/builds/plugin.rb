require 'wallboard/plugin'
require 'travis'

module Builds
    class Main < Wallboard::Plugin

        def get
            builds = Travis::Repository.find_all(member: self.settings['member']).map {|repo| repo.last_build()}.compact
            builds.map do |build|
                {
                    'name' => build.repository.name,
                    'status' => {'green' => 0, 'yellow' => 1, 'red' => 2}[build.color],
                    'commit' => build.commit.message,
                    'authors' => [{'name' => build.commit.author_name, 'email' => build.commit.author_email}]
                }
            end
        end

        def schedule(scheduler)
            scheduler.every '10s' do
                publish get
            end
        end
    end
end
