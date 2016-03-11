(function() {
  'use strict';

  angular.module('pa', [
    'pa.host',
    'pa.subsystems',
    'ui.bootstrap',
    'pa.services.host'
  ]);

})();

//  .config(function($stateProvider, $urlRouterProvider) {
//    $stateProvider
//      .state('pa', {
//        url:      '',
//        abstract: true
//        // templateUrl: 'subsystems/subsystems.tmpl.html',
//        // controller: 'MainCtrl'
//      })
//    ;
//
//    $urlRouterProvider.otherwise('/');
//  })
//});