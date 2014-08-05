angular.module('wb', ['ui.gravatar', 'gridster'])

.service('server', function($http) {
    this.plugins = function() {        
        return $http.get('plugin');
    }    
})
.controller('wb', function($scope, $timeout, server) {
    $scope.gridsterOpts = {
        columns: 50,
        defaultSizeX: 15,
        defaultSizeY: 10,
        pushing: true,
        floating: true,        
        margins: [10, 10],
        outerMargin: true,             
        resizable: {
           enabled: true,
           handles: 'n, e, s, w, ne, se, sw, nw'           
        },
        draggable: {
           enabled: true           
        }
    };
    
    server.plugins().success(function(plugins) {                
        $scope.plugins = plugins.available;
        $scope.widgets = plugins.enabled;
    });          
}).controller('widget', function($scope, $http, $injector) {        
    $scope.$on('loading', function(e, loading) {
        $scope.loading = loading;
    });
    
    $scope.get = function(url, data) {
        return $http.get('/plugin/' + $scope.widget.id + (url ? '/' + url : ''), data);
    }
    
    try {
        var child = $injector.get($scope.widget.name);
        if (child.start && $scope.widget.config) {
            $scope.$emit('loading', true);    
            child.start($scope, function() {
                $scope.$emit('loading', false);    
            });
        }
    } catch(err) {
        throw err;
    }
});