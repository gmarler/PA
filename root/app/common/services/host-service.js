(function() {
  'use strict';

  angular
    .module('pa.services.host', [])
    .factory('HostService', HostService);

  HostService.$inject = [ '$http' ];

  function HostService($http) {
    var hosts,
        memstats,
        PAServer  = "localhost",
        port      = "5000",
        hostname  = "nysbldo8",
        subsystem = "memstat",
        date      = moment().format('YYYY-MM-DD'),
        URLS = {
          FETCH:   'data/hosts.json',
          // MEMSTAT: 'data/memstat.json'
          MEMSTAT: 'http://' + PAServer + ':' + port + '/host/' + hostname + '/subsystem/' +
                    subsystem + '/date/' + date
        };

    var service = {
      hosts:          hosts,
      URLS:           URLS,
      PAServer:       PAServer,
      port:           port,
      hostname:       hostname,
      subsystem:      subsystem,
      date:           date,

      setPAServer:    setPAServer,
      getPAServer:    getPAServer,
      setHostname:    setHostname,
      getHostname:    getHostname,
      extract:        extract,
      cacheHosts:     cacheHosts,
      getHosts:       getHosts,
      getMemstat:     getMemstat
    };

    return service;

    // FUNCTION DEFINITIONS

    function setPAServer(server) {
      console.log("Updating PA Server to: " + server)
      PAServer = server;
    }

    function getPAServer() {
      return PAServer;
    }

    function setHostname(newHostname) {
      hostname = newHostname;
    }

    function getHostname() {
      return hostname;
    }

    function extract(result) {
      return result.data;
    }

    function cacheHosts(result) {
      hosts = extract(result);
      return hosts;
    }

    function getHosts() {
      var hostsURL = buildHostsURL();
      // return $http.get(URLS.FETCH).then(cacheHosts);

      return $http.get(hostsURL)
        .then(getHostsComplete)
        .catch(getHostsFailed);

      function getHostsComplete(response) {
        hosts = extract(response);
        // console.log(memstats);
        return hosts;
      }

      function getHostsFailed(error) {
        console.log("ERROR: XHR Failed for getHosts." + error.data);
      }
    }

    function getMemstat() {
      var myURL = buildMemstatURL();
      console.log("URL: " + myURL);

      // return $http.get(URLS.MEMSTAT)
      return $http.get(myURL)
                  .then(getMemstatComplete)
                  .catch(getMemstatFailed);

      function getMemstatComplete(response) {
        memstats = extract(response);
        // console.log(memstats);
        return memstats;
      }

      function getMemstatFailed(error) {
        console.log("ERROR: XHR Failed for getMemstat." + error.data);
      }
    }

    function buildHostsURL() {
      return 'http://' + PAServer + ':' + port + '/hosts';
    }

    function buildMemstatURL() {
      return 'http://' + PAServer + ':' + port + '/host/' + hostname + '/subsystem/' +
             subsystem + '/date/' + date;
    }

  }

})();