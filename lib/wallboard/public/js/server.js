angular.module('wb').service('server', function($http, $location, $q, $rootScope) {

    this.plugins = function() {
        return $http.get('plugin');
    }

    this.update = function(items) {
        return $http.put('plugin', items);
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
            if (message.plugin)
                $rootScope.$emit(message.plugin, message.data);
            else
                $rootScope.$emit('p', message);
        }

        return def.promise;
    }
});
