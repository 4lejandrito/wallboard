angular.module('wb').controller('wallboard', function($scope, $timeout, $location, server) {
    $scope.gridsterOpts = {
        columns: 20,
        defaultSizeX: 7,
        defaultSizeY: 4,
        pushing: true,
        floating: true,
        margins: [20, 20],
        outerMargin: true,
        isMobile: false,
        resizable: {
           enabled: true,
           handles: 'se'
        },
        draggable: {
           enabled: true
        }
    };

    $scope.$watch('plugins.enabled', function(items) {
        items && items.forEach(function(item) {
            server.update(item);
        });
    }, true);

    $scope.addPlugin = function(plugin) {
        server.create(plugin.name).success(function(plugin) {
            $scope.plugins.enabled.push(plugin);
        });
    }

    $scope.deletePlugin = function(plugin) {
        server.delete(plugin).success(function() {
            $scope.plugins.enabled.splice($scope.plugins.enabled.indexOf(plugin), 1);
        });
    }

    server.start().then(function(plugins) {
        $scope.plugins = plugins;
    });
});
