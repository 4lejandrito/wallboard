angular.module('wb').controller('wallboard', function($scope, $timeout, server) {
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
});