angular.module('pa.subsystems', [
  'pa.models.subsystems'
])
  .config(function($stateProvider) {
    $stateProvider
      .state('subsystems', {
        url: '/host/:hostID',
        views: {
          'subsystems@': {
            controller: 'SubsystemsCtrl',
            templateUrl: 'subsystems/subsystems.tmpl.html'
          }
        }
      })
  })
  .controller('SubsystemsCtrl', function SubsystemsCtrl($scope, $stateParams) {
    $scope.currentHostID = $stateParams.hostID;
  })
;