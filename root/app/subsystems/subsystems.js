(function() {
  'use strict';

  angular.module('pa.subsystems', [
    'pa.models.subsystems'
  ])
    
  .controller('SubsystemsCtrl', function (SubsystemsModel) {
    var vm = this;

    vm.subsystems = SubsystemsModel.getSubsystems();
    console.log(vm.subsystems);
  })

  .directive('subsystemNavbar', function () {
    return {
      restrict:    'AE',
      templateUrl: 'app/subsystems/subsystems.tmpl.html',
      replace:     false
    };
  })
  ;

})();