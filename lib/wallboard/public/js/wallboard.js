angular.module('wb').controller('wallboard', function(lodash, $filter, $rootScope, $scope, $timeout, $location, server) {
    $scope.gridsterOpts = {
        columns: 30,
        defaultSizeX: 7,
        defaultSizeY: 5,
        pushing: true,
        floating: true,
        margins: [10, 10],
        outerMargin: true,
        isMobile: false,
        resizable: {
           enabled: true,
           handles: 'n,s,e,w,nw,se,sw',
           stop: function(e, el, plugin) {
               server.update($scope.plugins.enabled);
           }
        },
        draggable: {
           enabled: true,
           stop: function(e, el, plugin) {
               server.update($scope.plugins.enabled);
           }
        }
    };

    $scope.addPlugin = function(plugin) {
        server.create(plugin.name);
    }

    $scope.deletePlugin = function(plugin) {
        server.delete(plugin);
    }

    $rootScope.$on('p', function(event, data) {
        $scope.$apply(function() {
            lodash.remove($scope.plugins.enabled, function (plugin) {
                return !lodash.find(data.enabled, {id: plugin.id});
            });
        });
        lodash.each($scope.plugins.enabled, function(plugin) {
            $scope.$apply(function() {
                lodash.merge(plugin, lodash.find(data.enabled, {id: plugin.id}));
            });
        });
        $scope.$apply(function() {
            lodash.merge($scope.plugins, data);
        });
    });

    server.start().then(function(plugins) {
        $scope.plugins = plugins;
        $scope.plugins.enabled = $filter('orderBy')($scope.plugins.enabled, ['layout.y','layout.x']);
    });
}).filter('trustAsResourceUrl', ['$sce', function($sce) {
    return function(val) {
        return $sce.trustAsResourceUrl(val);
    };
}]);
