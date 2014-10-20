require 'wallboard/plugin'
require 'travis'
require 'jenkins_api_client'

module Builds
    class Main < Wallboard::Plugin
        def get
            client = Travis::Client.new
            client.github_auth('1f5fe06e1616dacf11606678b841b527d5b4015a')
            builds = Travis::Repository.find_all(member: 'mdo').map {|repo| repo.last_build()}.compact
            JenkinsApi::Client.new(:server_url => 'https://jenkins.qa.ubuntu.com', :log_level => 2).job.list_all_with_details.map do |build|
                {
                    'name' => build["name"],
                    'status' => ({'blue' => 0, 'yellow' => 1, 'red' => 2}[build["color"]] or 0),
                    'commit' => 'I do not know',
                    'authors' => []
                }
            end
#            builds.map do |build|
#                {
#                    'name' => build.repository.name,
#                    'status' => {'green' => 0, 'yellow' => 1, 'red' => 2}[build.color],
#                    'commit' => build.commit.message,
#                    'authors' => [{'name' => build.commit.author_name, 'email' => build.commit.author_email}]
#                }
#            end
        end

        def schedule(scheduler)
            scheduler.every '10s' do
                #send get
            end
        end
    end
end
