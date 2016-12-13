angular
    .module('ng-bootstrap')
    .factory('Grid', [function () {

        return function (data, columns) {

            this.$orderBy = 'adaptation';

            this.$reverse = true;

            this.data = data || [];

            this.columns = columns || [];

            this.events = {};

            this.setData = function (data) {
                this.data = data;
            };

            this.bind = function ($key, $callback) {
                if (!this.events.hasOwnProperty($key)) this.events[$key] = [];
                this.events[$key].push($callback);
            };

            this.orderBy = function ($field) {
                this.$reverse = this.$orderBy === $field && this.$reverse;
                this.$orderBy = $field;
            };

        };

    }])
    .directive('grid', [function () {
        return {
            restrict: 'E',
            templateUrl: 'grid/grid.html',
            replace: true,
            scope: {
                ngRowClick: '&ngRowClick',
                grid: '=ngModel',
                $filter: '=filter'
            },
            link: function ($scope) {
                $scope.$orderBy = null;
                $scope.$reverse = false;
                $scope.$itemsPerPage = 25;
                $scope.$currentPage = 1;
                $scope.$totalItems = 0;
                $scope.$totalPages = 0;
            },
            controller: ["$scope", function ($scope) {

                $scope.orderBy = function ($column) {
                    $scope.$reverse = $scope.$orderBy === $column.field && !$scope.$reverse;
                    $scope.$orderBy = $column.field;
                };

                $scope.fire = function ($key, a, b, c) {
                    if ($scope.grid.events.hasOwnProperty($key)) {
                        angular.forEach($scope.grid.events[$key], function ($event) {
                            $event(a, b, c);
                        });
                    }
                };

            }]
        };
    }]);





