(function() {
  'use strict';

  angular
    .module('pa.host', [
      'pa.models.host'
    ])

    .controller('HostController', function ($scope, HostModel) {
      var vm = this;

      HostModel.getHosts()
        .then(function(result) {
          vm.hosts = result;
          console.log(vm.hosts)
        });

      $scope.$watch('vm.pa_server', function(newValue, oldValue) {
        console.log("NEW VALUE for vm.pa_server!");
        if (newValue !== oldValue) HostModel.setPAServer(newValue);
      });
    })

    .directive('hostInfo', hostInfo);

  function hostInfo() {
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
        scope.selectedHostTimeZone = hostobj.time_zone;
        scope.selectedHostId       = hostobj.id;
      };

      scope.availSubsystemsForHost = function(hostobj) {
        // Mock up for now
        scope.availSubsystems = [ 'Memory' ];
      }
    }
  }

})();