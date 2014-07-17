angular.module('wb').controller('builds', function($scope, $http) {
    $http.get("https://api.travis-ci.org/jobs", {headers: { Accept: "application/vnd.travis-ci.2+json" }}).success(function(result) {
        $scope.jobs = result.jobs;
        $scope.get('data');
    });
});