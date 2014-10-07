angular.module('wb').controller('plugin', function($scope, $http, $location, $injector) {

    function getURL(url) {
        return '/plugin/' + $scope.plugin.id + (url ? '/' + url : '');
    }

    $scope.$on('loading', function(e, loading) {
        $scope.loading = loading;
    });

    $scope.get = function(url, data) {
        return $http.get(getURL(url), data);
    }

    $scope.send = function(data) {
        return $http.post(getURL(), data);
    }

    try {
        var child = $injector.get($scope.plugin.name);
        if (child.start && $scope.plugin.config) {
            $scope.$emit('loading', true);
            child.start($scope, function() {
                $scope.$emit('loading', false);
            });
        }
    } catch(err) {
        throw err;
    }
});
