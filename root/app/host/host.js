(function() {
  'use strict';

  angular
    .module('pa.host', [
      'pa.services.host'
    ])

    .controller('HostController', function ($scope, HostService) {
      var vm = this;

      $scope.PAServer = "localhost";

      $scope.$watch('PAServer', function() {
        HostService.setPAServer($scope.PAServer);

        HostService.getHosts()
          .then(function(result) {
            vm.hosts = result;
            console.log(vm.hosts)
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
      };

      scope.availSubsystemsForHost = function(hostobj) {
        // Mock up for now
        scope.availSubsystems = [ 'Memory' ];
      }
    }
  }

  hostInfo.$inject = [ 'HostService' ];

})();