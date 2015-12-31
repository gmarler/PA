angular.module('pa.subsystems', [
  'pa.models.subsystems'
])
  .config(function($stateProvider) {
    $stateProvider
      .state('subsystems', {
        url: '/host/:hostID',
        views: {
          'subsystems@': {
            controller: 'SubsystemsCtrl as subsystemsCtrl',
            templateUrl: 'subsystems/subsystems.tmpl.html'
          }
        }
      })
  })
  .controller('SubsystemsCtrl', function ($stateParams, SubsystemsModel) {
    // $scope.currentHostID = $stateParams.hostID;

    var subsystemsCtrl = this;

    subsystemsCtrl.subsystems               = SubsystemsModel.getSubsystems();
    console.log(subsystemsCtrl.subsystems);
  })
;