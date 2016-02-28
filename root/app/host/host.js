(function() {
  'use strict';

  angular.module('pa.host', [
    'pa.models.host'
  ])

  .controller('HostCtrl', function (HostModel ) {
    var hostCtrl = this;

    //hostCtrl.currentHostID       = $stateParams.host.id;
    //hostCtrl.currentHostName     = $stateParams.host.name;
    //hostCtrl.currentHostTimeZone = $stateParams.host.time_zone;

    HostModel.getHosts()
      .then(function(result) {
        hostCtrl.hosts = result;
        console.log(hostCtrl.hosts)
      });
  })

  .directive('hostInfo', function() {
      return {
        restrict: 'AE',
        templateUrl: 'app/host/host.tmpl.html',
        replace:     true
        //controller:  function ($stateParams, SubsystemsModel) {
        //  var subsystemsCtrl = this;
        //
        //  subsystemsCtrl.subsystems               = SubsystemsModel.getSubsystems();
        //  console.log(subsystemsCtrl.subsystems);
        //}
      };
    }
  )
  ;

})();