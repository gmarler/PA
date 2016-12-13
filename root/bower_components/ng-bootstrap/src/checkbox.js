angular
    .module('ng-bootstrap')
    .directive('checkbox', [function () {
        return {
            restrict: 'E',
            templateUrl: 'checkbox/checkbox.html',
            replace: true,
            scope: {
                checked: '=',
                onCheck: '&'
            },
            link: function (scope) {
                if (scope.checked === undefined) {
                    scope.checked = false;
                }
            },
            controller: ["$scope", function ($scope) {
                $scope.check = function () {
                    event.stopPropagation();
                    event.preventDefault();
                    $scope.checked = !$scope.checked;
                    $scope.clicked = true;
                };
                $scope.$watch("checked", function () {
                    if ($scope.clicked) {
                        $scope.onCheck();
                        $scope.clicked = false;
                    }
                });
            }]
        };
    }]);

