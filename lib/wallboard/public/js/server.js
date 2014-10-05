angular.module('wb').service('server', function($http) {
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
});