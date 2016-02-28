(function() {
  'use strict';

  angular.module('pa.models.host', [])

  .service('HostModel', function ($http) {
    var model = this,
      URLS = {
        FETCH: 'data/hosts.json'
      },
      hosts;

    function extract(result) {
      return result.data;
    }

    function cacheHosts(result) {
      hosts = extract(result);
      return hosts;
    }

    model.getHosts = function () {
      return $http.get(URLS.FETCH).then(cacheHosts);
    }
  })

  ;

})();