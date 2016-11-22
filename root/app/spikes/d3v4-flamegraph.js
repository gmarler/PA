(function() {
  'use strict';

  function flameGraph() {
    var width = 1024;
    var height = 786;
    var selection = null;

    var partition =
      d3.partition()
        .size([width, height]);



    function update() {
      var root =
        d3.hierarchy(data,
          function (d) {
            return d.children;
          })
          .sum(
            function (d) {
              if (d.children) {
                return d.value;
              }
              else {
                return d.value;
              }
            }
          )
          .sort(null);

      // .value(function(d) {return d.v || d.value;})
      // .children(function(d) {return d.c || d.children;});

      partition(root);

    }

    function chart(s) {
      selection = s;

      selection.each(
        function (data) {
          var svg = d3.select(this)
            .append("svg:svg")
            .attr("width", width)
            .attr("height", height);
        }
      );

      update();
    }

    chart.height = function (newheight) {
      if (!arguments.length) { return height; }
      height = newheight;
      return chart;
    };

    chart.width = function (newwidth) {
      if (!arguments.length) { return width; }
      width = newwidth;
      return chart;
    };

    return chart;
  }

  if (typeof module !== 'undefined' && module.exports) {
    module.exports = flameGraph;
  }
  else {
    d3.flameGraph = flameGraph;
  }
})();
