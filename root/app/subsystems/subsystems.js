
(function() {
  'use strict';

  angular.module('pa.subsystems', [
      'pa.models.subsystems'
    ])

    .controller('SubsystemsCtrl', function (SubsystemsModel) {
      var subsystemsCtrl = this;

      subsystemsCtrl.subsystems = SubsystemsModel.getSubsystems();
      console.log(subsystemsCtrl.subsystems);
    })

    .directive('subsystemNavbar', function () {
      return {
        restrict: 'AE',
        templateUrl: 'app/subsystems/subsystems.tmpl.html'
        //controller:  function ($stateParams, SubsystemsModel) {
        //  var subsystemsCtrl = this;
        //
        //  subsystemsCtrl.subsystems               = SubsystemsModel.getSubsystems();
        //  console.log(subsystemsCtrl.subsystems);
        //}
      };
    })
  ;

})();