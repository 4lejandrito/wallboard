angular.module('wb').controller('plugin', function($rootScope, $scope, $injector, server) {

    $scope.plugin = window.plugin;

    server.start();

    $scope.$on('loading', function(e, loading) {
        $scope.loading = loading;
    });

    $scope.get = function(url, data) {
        return server.get($scope.plugin.id, data);
    }

    $scope.send = function(data) {
        return server.send($scope.plugin.id, data);
    }

    $rootScope.$on($scope.plugin.id, function(event, data) {
        $scope.$apply(function() {
            $scope.data = data;
        });
    });

    try {
        var child = $injector.get($scope.plugin.name);
    } catch(err) {
    }
    $scope.$emit('loading', true);
    if (child && child.start) {
        child.start($scope, function() {
            $scope.$emit('loading', false);
        });
    } else {
        server.get($scope.plugin.name).success(function(data) {
            $scope.data = data;
            $scope.$emit('loading', false);
        });
    }
}).controller('settings', function($scope, server) {
    $scope.$watch('plugin.settings', function() {
        server.settings($scope.plugin.id, $scope.plugin.settings);
    }, true);
});
