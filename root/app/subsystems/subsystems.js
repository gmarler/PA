(function() {
  'use strict';

  angular.module('pa.subsystems', [
    'pa.models.subsystems'
  ])
    
  .controller('SubsystemsController', function (SubsystemsModel) {
    var vm = this;

    SubsystemsModel.getSubsystems()
      .then(function(result) {
        vm.subsystems = result;
        vm.subsystem_metrics = [
          { name: "memstat" }
        ];
        console.log(vm.subsystems);
      });

  })

  .controller('DatepickerDemoController', function($scope) {
    $scope.today = function() {
      $scope.dt = new Date();
    };

    $scope.today();

    $scope.clear = function() {
      $scope.dt = null;
    };

    $scope.inlineOptions = {
      customClass: getDayClass,
      minDate: new Date(),
      showWeeks: true
    };

    $scope.dateOptions = {
      // dateDisabled: disabled,
      // formatYear: 'yy',
      // maxDate: new Date(2020, 5, 22),
      minDate: new Date(),
      startingDay: 1,
      customClass: testCustomClass
    };

    // Disable weekend selection
    function disabled(data) {
      var date = data.date,
        mode = data.mode;
      return mode === 'day' && (date.getDay() === 0 || date.getDay() === 6);
    }

    $scope.toggleMin = function() {
      $scope.inlineOptions.minDate = $scope.inlineOptions.minDate ? null : new Date();
      $scope.dateOptions.minDate = $scope.inlineOptions.minDate;
    };

    $scope.toggleMin();

    $scope.open = function() {
      $scope.popup.opened = true;
    };

    $scope.setDate = function(year, month, day) {
      $scope.dt = new Date(year, month, day);
    };

    $scope.formats = ['dd-MMMM-yyyy', 'yyyy/MM/dd', 'dd.MM.yyyy', 'shortDate'];
    $scope.format = $scope.formats[0];
    $scope.altInputFormats = ['M!/d!/yyyy'];

    $scope.popup = {
      opened: false
    };

    var tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    var afterTomorrow = new Date();
    afterTomorrow.setDate(tomorrow.getDate() + 1);
    $scope.events = [
      {
        date: tomorrow,
        status: 'full'
      },
      {
        date: afterTomorrow,
        status: 'partially'
      }
    ];

    function getDayClass(data) {
      var date = data.date,
        mode = data.mode;
      if (mode === 'day') {
        var dayToCheck = new Date(date).setHours(0,0,0,0);

        for (var i = 0; i < $scope.events.length; i++) {
          var currentDay = new Date($scope.events[i].date).setHours(0,0,0,0);

          if (dayToCheck === currentDay) {
            return $scope.events[i].status;
          }
        }
      }

      return '';
    }

    function testCustomClass(data) {
      console.log("testCustomClass:");
      console.log(data);
    }
  })

  .directive('subsystemNavbar', function () {
    return {
      restrict:    'AE',
      templateUrl: 'app/subsystems/subsystems.tmpl.html',
      replace:     false
    };
  })

  .directive('subsystemMetricsNavbar', function () {
    return {
      restrict:    'AE',
      templateUrl: 'app/subsystems/subsystem-metrics.tmpl.html',
      replace:     false
    };
  })

  ;

})();