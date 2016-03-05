(function() {
  'use strict';

  angular
    .module('pa')
    .directive('memstatD3', memstatD3);

  function memstatD3() {
    var directive = {
      restrict:  'AE',
      // templateUrl: 'app/host/host.tmpl.html',
      replace:   true,
      link:      link
    };

    return directive;

    function link(scope,element,attrs) {
      // Bottom margin makes room for the lengthy and rotated timestamps
      var margin = {top: 20, right: 20, bottom: 120, left: 75};
      var width  = parseInt(d3.select('body').style('width'));
      width      = width - margin.left - margin.right;
      // var height = parseInt(d3.select('body').style('height'));
      var height = 1000;
      height     = height - margin.top - margin.bottom;

      var formatPercent = d3.format(".0%");

      var x = d3.time.scale()
                .range([0, width]);

      var y = d3.scale.linear()
                .range([height, 0]);

      var color = d3.scale.category20();

      var xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom")
        .ticks(20)
        .tickFormat(d3.time.format("%Y-%m-%d %X"));

      var yAxis = d3.svg.axis()
        .scale(y)
        .orient("left")
        .tickFormat(formatPercent);

      var area = d3.svg.area()
        .x(function(d) { return x(d.timestamp); })
        .y0(function(d) { return y(d.y0); })
        .y1(function(d) { return y(d.y0 + d.y); });

      var stack = d3.layout.stack()
        .values(function(d) {
          // console.log(d.values);
          return d.values;
        });

      var svg = d3.select(element[0]).append("svg")
        .attr("width", width)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

      d3.json("data/memstat.json", function(error, data) {
        if (error) throw error;

        // Don't graph:
        // - The Epoch timestamp
        // - The Guest data (since it's currently always 0)
        // - The Total
        //
        // Specify the order in which we stack the data in the graph, from the Y axis up
        // NOTE: We're currently excluding: Guest and defump_prealloc
        var keys_in_order = [ "kernel_bytes", "exec_and_libs_bytes", "anon_bytes", "page_cache_bytes",
                              "zfs_metadata_bytes", "zfs_file_data_bytes", "free_cachelist_bytes",
                              "free_freelist_bytes" ];
        //color.domain(d3.keys(data[0])
        // Define the color map domain in key order
        color.domain(keys_in_order
          .filter(function(key) {
            return (key !== "timestamp" && key !== "total_bytes" && key !== "guest"); }));

        data.forEach(function(d) {
          // convert Epoch seconds timestamp into Epoch millisec timestamp so it can be converted
          // into a Javascript Date object.
          // WARNING: This will be in the local timezone of the browser you load this into!
          d.timestamp = new Date((d.timestamp * 1000));
          // console.log(d);
        });

        var memtypes = stack(color.domain().map(function(name) {
          // console.log(name);
          return {
            name: name,
            values: data.map(function(d) {
              return {timestamp: d.timestamp, y: d[name] / d.total_bytes };
            })
          };
        }));

        x.domain(d3.extent(data, function(d) { return d.timestamp; }));

        var memtype = svg.selectAll(".memtype")
          .data(memtypes)
          .enter().append("g")
          .attr("class", "memtype");


        var paths =
          memtype.append("path")
            .attr("class", "area")
            .attr("d", function(d) { return area(d.values); })
            .style("fill", function(d) { return color(d.name); });

        // Highlight / unhighlight individual areas in the stack as we pass into and out of them
        paths
          .on('mouseover', function (d) {
            d3.select(this)
              .attr('stroke-width', 3)
              .attr('fill', d3.rgb(color(d.name)).brighter())
              .attr('stroke', color(d.name));
          })
          .on('mouseout', function(d) {
            d3.select(this)
              .attr('stroke-width', 0)
              .attr('fill', color(d.name));
          });


        memtype.append("text")
          .datum(function(d) { return {name: d.name, value: d.values[d.values.length - 1]}; })
          .attr("transform", function(d) { return "translate(" + x(d.value.timestamp) + "," + y(d.value.y0 + d.value.y / 2) + ")"; })
          .attr("x", -600)
          .attr("dy", ".35em")
          .attr('font-size', '14px')
          .text(function(d) {
            var regex1 = /_bytes$/;
            var regex2 = /^(.)/;
            var regex3 = /_/g;
            var regex4 = /zfs/gi
            var cvt_name = d.name;
            cvt_name = cvt_name.replace(regex1, "");
            cvt_name = cvt_name.replace(regex2,function (s) { return s.toUpperCase(); });
            cvt_name = cvt_name.replace(regex3, " ");
            // cvt_name = cvt_name.replace(/\_(.)/g, function (s = $1) { return s.toUpperCase() });
            cvt_name = cvt_name.replace(regex4,function (s) { return s.toUpperCase(); });
            return cvt_name;
          });

        svg.append("g")
          .attr("class", "x axis")
          .attr("transform", "translate(0," + height + ")")
          .call(xAxis)
          .selectAll("text")
            .style("text-anchor", "end")
            .attr("dx", "-.8em")
            .attr("dy", ".15em")
            .attr("transform", function(d) {
                return "rotate(-55)"
                });

        svg.append("g")
          .attr("class", "y axis")
          .call(yAxis);
      });

    }
  }

})();