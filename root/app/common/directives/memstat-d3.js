(function() {
  'use strict';

  angular
    .module('pa')
    .directive('memstatD3', memstatD3);

  memstatD3.$inject = [ 'HostService', '$log' ];

  memstatD3Controller.inject = [ '$scope', '$interval', '$window', '$log' ];

  function memstatD3Controller($scope, $element, $attrs, HostService, $interval, $window, $log) {
    var vm = this;

    // Allow window resizing
    //$window.addEventListener('resize', function() {
    //  $scope.$broadcast('vm.windowResize');
    //});

    // Grab the data when we start ...
    $log.debug("INITIAL DATA PULL...");
    HostService.getHostDateSubsystemMetric(
      function (result) {
        vm.d3data = result;
        vm.TZ     = HostService.getHostTimeZone();
        HostService.data_pullable = false;
      },
      "memory", "memstat"
    );

    // ... update every 30 seconds thereafter
    // Grab the intervalID so we can eliminate it if we so choose later
    var intervalID =
      $interval(function() {
        $log.debug("PERIODIC DATA PULL");
        HostService.getHostDateSubsystemMetric(
          function (result) {
            vm.d3data = result;
            vm.TZ     = HostService.getHostTimeZone();
            HostService.data_pullable = false;
          },
          "memory", "memstat"
        );
      }, 30000);

    // Clean up the interval timer before we kill this
    // controller
    $scope.$on('$destroy', function() {
      $log.debug("CLEANING UP");
      if (intervalID) { $interval.cancel(intervalID); }
    });
  }

  function memstatD3(HostService, $log) {
    // Define constants and helpers used for this directive
    // Bottom margin makes room for the lengthy and rotated timestamps
    var margin = {top: 20, right: 155, bottom: 140, left: 75};
    var width  = 1600;
    // var width  = parseInt(d3.select('body').style('width')) - 100;
        width      = width - margin.left - margin.right;
    // var height = parseInt(d3.select('body').style('height'));
    // var height = 1000;
    var height = 1024;
        height = height - margin.top - margin.bottom;
    // Navigation/Brushing Chart below the main chart
    var navWidth = width,
        navHeight = 100 - margin.top - margin.bottom;

    // Specify the order in which we stack the data in the graph, from the Y axis up
    // NOTE: We're currently excluding: Guest and defump_prealloc
    var keys_in_order = [ "kernel_bytes", "exec_and_libs_bytes", "anon_bytes", "page_cache_bytes",
                          "zfs_metadata_bytes", "zfs_file_data_bytes", "free_cachelist_bytes",
                          "free_freelist_bytes" ];

    var formatPercent = d3.format(".0%");
    var formatRAM     = d3.format(".0f");

    var xAxisGroup,
        yAxisGroup,
        yAxisGroupRAM;

    var xAxisScale = d3.time.scale()
      .range([0, width]);

    var yAxisScale = d3.scale.linear()
      .range([height, 0]);
    // Set the Y Axis Scale Domain - it's static in this case at 0 to 100 percent,
    // unlike the X Axis Scale, which is constantly increasing.
    yAxisScale.domain([0, 1]);

    // We don't know the domain until we read the first data; wait till then
    // to set it, and only set it once
    var totalRAMinBytes;
    //var yAxisScaleRAM = d3.scale.linear()
    //  .range([height, 0]);
    var yAxisScaleRAM = d3.byte.scale()
      .range([height, 0]);

    var color = d3.scale.category20();

    // NOTE: The tickFormat() is replaced in the code that watches for updates in d3data.
    // TODO: find all the places where the tickFormat() needs to be adjusted, as there is
    //       more than one.  The issue we see is that the timestamps are initially in the
    //       TZ local to the browser where this is viewed, then later is updated to be
    //       the TZ of the host where the data was originally collected.
    var xAxis = d3.svg.axis()
      .scale(xAxisScale)
      .orient("bottom")
      .ticks(20)
      .tickFormat(d3.time.format("%Y-%m-%d %X"));


    var yAxis = d3.svg.axis()
      .scale(yAxisScale)
      .orient("left")
      .tickFormat(formatPercent);

    // display a y axis on the right side of the chart that shows actual RAM size
    var yAxisRAM = d3.svg.axis()
      .scale(yAxisScaleRAM)
      .orient("right");

    var area = d3.svg.area()
      .x(function(d) { return xAxisScale(d.timestamp); })
      .y0(function(d) { return yAxisScale(d.y0); })
      .y1(function(d) { return yAxisScale(d.y0 + d.y); });

    var stack = d3.layout.stack()
      .values(function(d) {
        return d.values;
      });


    var directive = {
      restrict:         'AE',
      // templateUrl:   'app/host/host.tmpl.html',
      replace:          true,
      link:             link,
      scope:     {
        d3data:     '=',
        TZ:         '='
      },
      controller:        memstatD3Controller,
      controllerAs:     'vm',
      bindToController: true // because the scope is isolated
    };

    return directive;

    function link(scope, element, attrs, vm) {
      // initialization, done once per directive tag in template. If my-directive is within an
      // ng-repeat-ed template then it will be called every time ngRepeat creates a new copy of the template.

      // This is the boolean that determines if we are doing this for the first time,
      // where the elements get appended.  All subsequent updates to d3data will result in
      // the enter/update/exit pattern for D3.
      var first_run = true;
      var memtypes,
          memtype,
          paths,
          legend;

      var legendWidth = 36;
      var svg = d3.select(element[0])
        .append("svg")
          .attr("width",  width  + margin.left + margin.right + legendWidth)
          .attr("height", height + margin.top  + margin.bottom);

      var chart = svg
          .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

      // Create the Navigation/Brushing chart after the regular chart
      var navChart = d3.select(element[0])
        .append('svg')
        .classed('navigator', true)
        .attr('width', navWidth + margin.left + margin.right)
        .attr('height', navHeight + margin.top + margin.bottom)
        .append('g')
        .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

      // Define the color map domain in key order
      color.domain(keys_in_order
        .filter(function(key) {
          return (key !== "timestamp" && key !== "total_bytes" && key !== "guest"); }));

      // Whenever things in the view change such that a 'pull' of the D3 data by
      // the HostService can be attempted, go ahead and initiate that action immediately,
      // instead of waiting for the recurring update to come along and do the update
      // later.
      scope.$watch(
        function() {
          return HostService.data_pullable;
        },
        function(newVal, oldVal) {
          if (newVal) {
            $log.debug("data_pullable has been flipped!");
            HostService.getHostDateSubsystemMetric(
              function (response) {
                vm.d3data = response;
                vm.TZ     = HostService.getHostTimeZone();
                HostService.data_pullable = false;
              },
              "memory", "memstat"
            );
          }
        }
      );

      // whenever the bound 'TZ' timezone changes, execute this
      scope.$watch('vm.TZ', function(newTZ, oldTZ) {
        console.log('TIMEZONE UPDATED!');
        // This is the point at which we reformat the x-axis timestamp to display in the time
        // zone of the host where the data was collected.  This tickFormat() replaces that which
        // was set above where xAxis was defined.
        var hostTZ = vm.TZ;
        xAxis
          .tickFormat(function(d) {
            return moment(d).tz(hostTZ).format("MM-DD-YYYY HH:mm:ss");
          });
      });

      // whenever the bound 'd3data' expression changes, execute this
      scope.$watch('vm.d3data', function (newd3data, oldd3data) {
        // console.log("GOT NEW DATA!");

        $log.debug(vm);
        // Don't graph:
        // - The Epoch timestamp
        // - The Guest data (since it's currently always 0)
        // - The Total
        //

        // clear the elements inside of the directive
        // chart.selectAll('*').remove();

        // if 'd3data' is undefined, exit
        if (!newd3data) {
          return;
        }

        newd3data.forEach(function(d) {
          // convert Epoch seconds timestamp into Epoch millisec timestamp so it can be converted
          // into a Javascript Date object later.
          // WARNING: This will be in the local timezone of the browser you load this into!
          // TODO: Now that we've moved to moment for this, do we really need to do this step anymore?
          d.timestamp = new Date((d.timestamp * 1000));
        });

        // Only run this the first time through - to create things like SVG groupings
        // the first time only
        if (first_run) {
          $log.debug("First Time Through memstat-d3 directive!");
          // ...
          legend = d3.select('svg').selectAll(".legend")
            .data(color.domain().slice().reverse())
            .enter()
            .append("g")
            .attr("class", "legend")
            .attr("transform", function(d,i) { return "translate(35," + i * 25 + ")"; });

          legend.append("rect")
            .attr("x", width + margin.left + margin.right - 18)
            .attr("width", 18)
            .attr("height", 18)
            .style("fill", color);

          legend.append("text")
            .attr("x", width + margin.left + margin.right - 24)
            .attr("y", 9)
            .attr("dy", ".35em")
            .style("text-anchor", "end")
            .text(function(d) {
              var regex1 = /_bytes$/;
              var regex2 = /^(.)/;
              var regex3 = /_/g;
              var regex4 = /zfs/gi
              var cvt_name = d;
              cvt_name = cvt_name.replace(regex1, "");
              cvt_name = cvt_name.replace(regex2,function (s) { return s.toUpperCase(); });
              cvt_name = cvt_name.replace(regex3, " ");
              // cvt_name = cvt_name.replace(/\_(.)/g, function (s = $1) { return s.toUpperCase() });
              cvt_name = cvt_name.replace(regex4,function (s) { return s.toUpperCase(); });
              return cvt_name;
            });

          // Create X Axis g Element
          xAxisGroup =
            chart.append("g")
              .attr("class", "x axis")
              .attr("transform", "translate(0," + height + ")")
              .call(xAxis);

          // Create Y Axis g Element
          yAxisGroup =
            chart.append("g")
              .attr("class", "y axis")
              .call(yAxis);

          totalRAMinBytes = newd3data[0].total_bytes;
          console.log('TOTAL RAM IN BYTES: ' + totalRAMinBytes);
          yAxisScaleRAM
            .domain([0, totalRAMinBytes]);

          // Create Y Axis RAM g Element
          yAxisGroupRAM =
            chart.append("g")
              .attr("class", "y axis RAM")
              .attr("transform", "translate(" + width + ",0)")
              .call(yAxisRAM);

          first_run = false;
        }

        UpdatePattern(newd3data);

        function UpdatePattern(udata) {

          // Recalculate the xAxisScale
          xAxisScale
            .domain(d3.extent(udata, function(d) { return d.timestamp; }));
          // Recalculate the yAxisScale - UNNECESSARY, as it's static in this directive
          // Recalculate the yAxisScaleRAM, as we may change from machine to machine
          // TODO: Change from newd3data[0] to newd3data[<last index>]
          totalRAMinBytes = newd3data[0].total_bytes;
          yAxisScaleRAM
            .domain([0, totalRAMinBytes]);

          // Update values for each area to be stacked
          memtypes = stack(color.domain().map(function(name) {
            return {
              name: name,
              values: udata.map(function(d) {
                var obj = {timestamp: d.timestamp, y: d[name] / d.total_bytes };
                return obj;
              })
            };
          }));

          // GENERAL UPDATE PATTERN
          // JOIN - Join new/updated data
          // var binding = svg.selectAll('div').data(data);
          var memtypeSelection =
            chart.selectAll(".memtype")
              .data(memtypes);

          //
          // UPDATE - Update existing elements as needed
          // binding.style('background-color', 'blue');
          // Apply the updated xAxisScale to the xAxis
          xAxis.scale(xAxisScale);
          // Update the xAxis
          chart
            .select(".x")
            .transition()
            .duration(1000)
            .call(xAxis);
          // Update the RAM Y Axis
          chart
            .select(".RAM")
            .transition()
            .duration(1000)
            .call(yAxisRAM);
          // Add the latest values to each area's path
          memtypeSelection
            .select("path")
            .transition()
            .duration(1000)
            .attr("d", function(d) { return area(d.values); });

          //
          // ENTER - Create new elements as needed
          // binding.enter().append('div');
          memtypeSelection
            .enter()
            .append("g")
            .append("path")
            .attr("class", "area")
            .attr("d", function(d) { return area(d.values); })
            .style("fill", function(d) { return color(d.name); });

          //
          // UPDATE + ENTER - Appending to the enter selection expands the update selection
          // to include the entering elements; so operations on the update selection after
          // enter() will apply to both entering and updating nodes
          // binding.style('width', function(d) { return d * 50 + 'px'; })
          //        .text(function(d) { return d; });
          // Update X Axis Text
          xAxisGroup
            .selectAll("text")
            .style("text-anchor", "end")
            .attr("dx", "-.8em")
            .attr("dy", ".15em")
            .attr("transform", function(d) {
              return "rotate(-55)"
            });

          // Y Axis Does not require updating in this case...

          memtypeSelection
            .attr("class", "memtype");

          //
          // EXIT - Remove old nodes as needed
          // binding.exit().style('background-color', 'red').remove();
          //
          memtypeSelection.exit().remove();
        }

        //memtype =
        //  chart.selectAll(".memtype")
        //     .data(memtypes)
        //     .enter()
        //     .append("g")
        //     .attr("class", "memtype");
        //
        //paths =
        //  memtype.append("path")
        //         .attr("class", "area")
        //         .attr("d", function(d) { return area(d.values); })
        //         .style("fill", function(d) { return color(d.name); });
        //
        //// Highlight / unhighlight individual areas in the stack as we pass into and out of them
        //paths
        //  .on('mouseover', function (d) {
        //    d3.select(this)
        //      .attr('stroke-width', 3)
        //      .attr('fill', d3.rgb(color(d.name)).brighter())
        //      .attr('stroke', color(d.name));
        //  })
        //  .on('mouseout', function(d) {
        //    d3.select(this)
        //      .attr('stroke-width', 0)
        //      .attr('fill', color(d.name));
        //  });
        //
        //// Update X Axis
        //xAxisGroup
        //  .selectAll("text")
        //  .style("text-anchor", "end")
        //  .attr("dx", "-.8em")
        //  .attr("dy", ".15em")
        //  .attr("transform", function(d) {
        //    return "rotate(-55)"
        //  });

        // Y Axis Does not require updating in this case...

        // resize();
      });

      function resize() {
        console.log("RESIZING!");
        console.log("WIDTH: " + element[0].clientWidth);
        svg.attr("width",  element[0].clientWidth);
        svg.attr("height", element[0].clientWidth); //It's a square
      }

      scope.$on('vm.windowResize',resize);
    }
  }

})();