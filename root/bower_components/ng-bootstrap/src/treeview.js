angular
    .module('ng-bootstrap')
    .factory("Event", [function () {
        return function () {
            this.events = [];
            this.on = function ($type, $event) {
                if (!this.events[$type]) {
                    this.events[$type] = [];
                }
                this.events[$type].push($event);
            };
            this.fire = function ($type) {
                if (!this.events[$type]) {
                    return;
                }
                for (var i in this.events[$type]) {
                    if (this.events[$type].hasOwnProperty(i)) {
                        this.events[$type][i]();
                    }
                }
            };
        };
    }])
    .factory('Node', [function () {
        return function Node($attributes, $root, $parent) {
            var that = this;
            this.root = $root;
            this.parent = $parent || null;
            this.nodes = [];
            this.expanded = false;
            this.checked = false;
            this.depth = this.parent ? this.parent.depth + 1 : 1;

            angular.forEach($attributes, function ($value, $key) {
                if ($key !== 'nodes') {
                    that[$key] = $value;
                }
            });

            angular.forEach($attributes["nodes"], function ($node) {
                that.nodes.push(new Node($node, $root, that));
            });

            this.filter = function ($filter) {
                var nodes = [];
                for (var i in this.nodes) {
                    if (this.nodes.hasOwnProperty(i)) {
                        var t = $filter(this.nodes[i]);
                        if (t) {
                            nodes.push(t);
                        }
                        nodes = nodes.concat(this.nodes[i].filter($filter));
                    }
                }
                return nodes;
            };

            this.toggle = function () {

                if (!this.nodes.length) {
                    return;
                }

                this.expanded = !this.expanded;

            };

            this.onCheck = function () {
                this.checkParent(this.checked);
                this.checkChildren(this.checked);
                this.root.event.fire("checked");
            };

            this.checkParent = function (checked) {

                if (!this.parent) {
                    return;
                }

                for (var i in this.parent.nodes) {
                    if (this.parent.nodes.hasOwnProperty(i)) {
                        if (this.parent.nodes[i].checked !== checked) {
                            checked = 0.5;
                            break;
                        }
                    }
                }

                this.parent.checked = checked;

                this.parent.checkParent(checked);

            };

            this.checkChildren = function (checked) {

                for (var i in this.nodes) {
                    if (this.nodes.hasOwnProperty(i)) {
                        this.nodes[i].checked = checked;
                        this.nodes[i].checkChildren(checked);
                    }
                }

            };
        };
    }])
    .factory('TreeModel', ["Node", "Event", function (Node, Event) {
        return function ($tree) {

            var root = new Node($tree, this);

            this.nodes = root.nodes;

            this.event = new Event;

            this.filter = root.filter;
        };
    }])
    .directive("treeview", ["$compile", "$templateCache", function ($compile, $templateCache) {
        var template = $templateCache.get("treeview/treeview.html");
        return {
            restrict: 'E',
            replace: true,
            scope: {
                nodes: '='
            },
            link: function (scope, element) {
                scope.$watch('nodes', function () {
                    if (scope.nodes && scope.nodes.length) {
                        element.html($compile(template)(scope));
                    }
                });
            }
        };
    }]);
