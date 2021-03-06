(function() {
  'use strict';

  angular
    .module('pa.host', [
      'pa.services.host'
    ])

    .controller('HostController', function ($scope, HostService) {
      var vm = this;

      // Temporary list of initial PA Servers for dev / testing
      vm.pa_servers = [
        '192.168.55.101',
        'nydevsol10.dev.bloomberg.com'
      ];

      $scope.$watch('PAServer', function() {
        console.log("PAServer changed to: " + $scope.PAServer);
        HostService.setPAServer($scope.PAServer);

        HostService.getHosts()
          .then(function(result) {
            vm.hosts = result;
            console.log(vm.hosts)
            // Register this status message: Pulled list of hosts from PA Server
            vm.getHostError   = undefined;
            vm.getHostSuccess = "Pulled list of hosts from PA Server";
          })
          .catch(function(error) {
            // Register this message: Unable to pull list of hosts from PA Server
            console.log("host.js call to getHosts() failed");
            vm.getHostError   = "Unable to pull list of hosts from PA Server";
            vm.getHostSuccess = undefined;
          });
      });


    })

    .directive('hostInfo', hostInfo);

  function hostInfo(HostService) {
    var directive = {
      restrict:    'AE',
      templateUrl: 'app/host/host.tmpl.html',
      replace:     false,
      link:        link
    };
    return directive;

    function link(scope, element, attrs) {

      scope.getHostError         = undefined;
      scope.getHostSuccess       = undefined;

      scope.selectedHostName     = "Select Hostname";
      scope.selectedHostTimeZone = "N / A";
      scope.selectedHostId       = undefined;

      // currently available list of subsystems with info for the current host
      scope.availSubsystems      = undefined;

      scope.hostSelected = function (hostobj) {
        // Reset list of available subsystems
        scope.availSubsystems      = undefined;

        // set up info related to the host just selected
        scope.selectedHostName     = hostobj.name;
        HostService.setHostname(hostobj.name);
        scope.selectedHostTimeZone = hostobj.time_zone;
        HostService.setHostTimeZone(hostobj.time_zone);
        scope.selectedHostId       = hostobj.id;
        HostService.setHostID(hostobj.id);
        // Alert those watching that something has changed
        HostService.data_pullable = true;
      };

      scope.availSubsystemsForHost = function(hostobj) {
        // Mock up for now
        scope.availSubsystems = [ 'Memory' ];
      }
    }
  }

  hostInfo.$inject = [ 'HostService' ];

})();