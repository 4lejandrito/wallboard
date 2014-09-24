angular.module('wb', ['ui.gravatar', 'gridster', 'dcbImgFallback'])

.service('server', function($http) {
    this.plugins = function() {        
        return $http.get('plugin');
    }    
    this.update = function(item) {
        return $http.post('plugin/' + item.id + '/layout', item.layout);
    }
    this.create = function(name) {
        return $http.post('plugin', {name: name});
    }
    
    this.delete = function(item) {
        return $http.delete('plugin/' + item.id);
    }
})
.controller('wb', function($scope, $timeout, server) {
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
    
    $scope.$watch('widgets', function(items) {
        items && items.forEach(function(item) {
            server.update(item);
        });
    }, true);
    
    $scope.refresh = function() {
        server.plugins().success(function(plugins) {                
            $scope.plugins = plugins.available;
            $scope.widgets = plugins.enabled;
        });  
    }
    
    $scope.addWidget = function(widget) {
        server.create(widget.name).success(function() {
           $scope.refresh(); 
        });
    }
    
     $scope.deleteWidget = function(widget) {
        server.delete(widget).success(function() {
           $scope.refresh(); 
        });
    }
    
    $scope.refresh();
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