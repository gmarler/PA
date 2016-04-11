(function() {
  'use strict';

  angular
    .module('pa.services.host', [])
    .factory('HostService', HostService);

  HostService.$inject = [ '$http' ];

  function HostService($http) {
    var hosts,
        memstats,
        PAServer,
        port      = "5000",
        hostname,
        hostID,
        hostTimeZone,
        subsystem,
        date      = moment().format('YYYY-MM-DD');

    var service = {
      data_pullable:   false,
      hosts:           hosts,
      PAServer:        PAServer,
      port:            port,
      hostname:        hostname,
      hostID:          hostID,
      hostTimeZone:    hostTimeZone,
      subsystem:       subsystem,
      date:            date,

      setPAServer:                  setPAServer,
      getPAServer:                  getPAServer,
      setHostname:                  setHostname,
      getHostname:                  getHostname,
      setHostID:                    setHostID,
      getHostID:                    getHostID,
      setHostTimeZone:              setHostTimeZone,
      getHostTimeZone:              getHostTimeZone,
      setDate:                      setDate,
      extract:                      extract,
      cacheHosts:                   cacheHosts,
      getHosts:                     getHosts,
      getMemstat:                   getMemstat,
      getHostSubsystemDateMetric:   getHostSubsystemDateMetric
    };

    return service;

    // FUNCTION DEFINITIONS

    function setPAServer(server) {
      console.log("Updating PA Server to: " + server);
      PAServer = server;
      // data_pullable = true;
    }

    function getPAServer() {
      return PAServer;
    }

    function setHostname(newHostname) {
      hostname = newHostname;
      // data_pullable = true;
    }

    function getHostname() {
      return hostname;
    }

    function setHostID(hostid) {
      hostID = hostid;
    }

    function getHostID() {
      return hostID;
    }

    function setHostTimeZone(timezone) {
      hostTimeZone = timezone;
    }

    function getHostTimeZone() {
      return hostTimeZone;
    }

    function setDate(newdate) {
      date = moment(newdate).format('YYYY-MM-DD');
      // data_pullable = true;
      return date;
    }

    function extract(result) {
      return result.data;
    }

    function cacheHosts(result) {
      hosts = extract(result);
      return hosts;
    }

    function getHosts() {
      console.log("CALLING HostService.getHosts()");
      var hostsURL = buildHostsURL();

      return $http.get(hostsURL)
        .then(getHostsComplete)
        .catch(getHostsFailed);

      function getHostsComplete(response) {
        hosts = extract(response);
        console.log("HostService.getHosts() returns:");
        console.log(hosts);
        return hosts;
      }

      function getHostsFailed(error) {
        console.log("ERROR: XHR Failed for getHosts." + error.data);
      }
    }

    function getMemstat() {
      var myURL = buildMemstatURL();
      console.log("URL: " + myURL);

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
      var URL = 'http://' + PAServer + ':' + port + '/hosts';
      console.log("buildHostsURL built: " + URL);
      return URL;
    }

    function buildMemstatURL() {
      return 'http://' + PAServer + ':' + port + '/host/' + hostname + '/subsystem/' +
             subsystem + '/date/' + date;
    }

    function getHostSubsystemDateMetric(callback, subsystem, metric) {
      // Build REST request to fetch data for this particular subsystem and metric
      // TODO: Will need to change this to:
      //       'http://' + PAServer + ':' + port + '/host/' + hostname +
      //       '/subsystem/' + subsystem + '/metric/' + metric +
      //       '/date/' + date;
      var myURL = 'http://' + PAServer + ':' + port + '/host/' + hostname + '/subsystem/' +
                  metric + '/date/' + date;
      console.log("getHostSubsystemDateMetric URL: " + myURL);

      // If any of the items are undefined, then don't perform the request, just return an empty
      // array
      if ((PAServer === undefined) || (port === undefined) || (hostname === undefined) ||
          (metric === undefined) || (date === undefined)) {
        return [];
      }

      // Perform request
      return $http.get(myURL)
        .then(getMemstatComplete)
        .catch(getMemstatFailed);

      function getMemstatComplete(response) {
        memstats = extract(response);
        callback(memstats);
        // return memstats;
      }

      function getMemstatFailed(error) {
        console.log("ERROR: XHR Failed for getMemstat." + error.data);
      }
    }

  }

})();