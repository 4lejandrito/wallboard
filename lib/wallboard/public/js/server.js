angular.module('wb').service('server', function($http, $location, $q, $rootScope) {

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

    this.get = function(plugin, data) {
        return $http.get('plugin/' + plugin);
    }

    this.send = function(plugin, data) {
        return $http.post('plugin/' + plugin, data);
    }

    this.start = function() {
        var def = $q.defer(), self = this, ws = new WebSocket('ws://' + $location.host() + ':' + $location.port());

        ws.onopen = function() {
            self.plugins().success(def.resolve);
        }

        ws.onmessage = function(data) {
            var message = JSON.parse(data.data);
            $rootScope.$emit(message.plugin, message.data);
        }

        return def.promise;
    }
});
