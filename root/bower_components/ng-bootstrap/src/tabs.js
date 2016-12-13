angular
    .module('ng-bootstrap')
    .directive('tabs', [function () {
        return {
            restrict: 'E',
            transclude: true,
            templateUrl: 'tabs/tabs.html',
            scope: {},
            replace: true,
            controller: ["$scope", function ($scope) {
                var panes = $scope.panes = [];
                $scope.activate = function (pane) {
                    if (pane.disabled) return;
                    angular.forEach(panes, function (pane) {
                        pane.active = false;
                    });
                    pane.active = true;
                };
                this.addPane = function (pane) {
                    if (panes.length == 0) $scope.activate(pane);
                    panes.push(pane);
                }
            }]
        };
    }])
    .directive('pane', [function () {
        return {
            require: '^tabs',
            restrict: 'E',
            transclude: true,
            scope: {
                title: '@',
                disabled: '='
            },
            templateUrl: 'tabs/pane.html',
            replace: true,
            link: function (scope, element, attrs, tabsController) {
                tabsController.addPane(scope);
            }
        };
    }]);





