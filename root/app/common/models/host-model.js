(function() {
  'use strict';

  angular
    .module('pa.models.host', [])
    .factory('HostModel', HostModel);

  HostModel.$inject = [ '$http' ];

  function HostModel( $http ) {
    var hosts,
        URLS = {
          FETCH: 'data/hosts.json'
        },
        PAServer;

    var service = {
      hosts:        hosts,
      URLS:         URLS,
      PAServer:     PAServer,

      extract:      extract,
      cacheHosts:   cacheHosts,
      getHosts:     getHosts,
      setPAServer:  setPAServer,
      getPAServer:  getPAServer
    };


    function extract(result) {
      return result.data;
    }

    function cacheHosts(result) {
      hosts = extract(result);
      return hosts;
    }

    function getHosts() {
      return $http.get(URLS.FETCH).then(cacheHosts);
    }
  }

})();