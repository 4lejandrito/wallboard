angular.module('wb').service('builds', function($http) {
    this.start = function($scope, done) {
        $scope.Math = Math;

        $http.post(
            'https://api.travis-ci.org/auth/github',
            {github_token:"1f5fe06e1616dacf11606678b841b527d5b4015a"},
            {headers: {Accept: "application/vnd.travis-ci.2+json"}}
        ).then(function(response) {
            $scope.token = response.data.access_token;
            return $http.get(
                "https://api.travis-ci.org/repos?member=" + $scope.widget.config.username,
                { headers: { Accept: "application/vnd.travis-ci.2+json", Authorization: 'token ' + $scope.token
            }});
        }).then(function(response) {        
            $scope.jobs = [];
            response.data.repos.forEach(function(repo) {            
                done();
                $http.get(
                    "https://api.travis-ci.org/builds/" + repo.last_build_id,
                    { headers: { Accept: "application/vnd.travis-ci.2+json", Authorization: 'token ' + $scope.token
                }}).success(function(data) {
                    $scope.jobs.push({
                        name: repo.slug.split('/')[1],
                        status: {passed: 0, errored: 1, failed: 2}[data.build.state],                
                        commit: data.commit.message,
                        authors: [
                            {name: data.commit.author_name, email: data.commit.author_email}                        
                        ]
                    });
                });            
            });
        });

        $scope.addBuild = function() {
            $scope.jobs.push(
                {
                    name: 'Ask Widgets',
                    status: Math.floor(Math.random() * 3),                
                    commit: 'Everything fucked up',
                    authors: [
                        {name: 'Alejandro Tardin', email: 'alejandro@tardin.com'},
                        {name: 'Pau Folque', email: 'paufolque@gmail.com'}                    
                    ]
                }
            );
        }
    }
});