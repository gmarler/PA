;(function (d3) {
  'use strict';

  d3.byte = {};

  d3.byte.scale = function () {
    return d3_byte_scale(d3.scale.linear());
  };

  function d3_byte_scale(linear) {
    function scale(x) {
      return linear(x);
    }

    scale.ticks = function (m) {
      return d3_byte_scale_ticks(scale.domain(), m);
    };

    scale.tickFormat = function (n, unit, showLabels) {
      var l = arguments.length;

      if (l === 0) {
        n = 8;
        unit = null;
        showLabels = true;
      } else if (l === 1) {
        unit = null;
        showLabels = true;
      } else if (l === 2) {
        if (typeof unit !== 'string') {
          showLabels = !!unit;
          unit = null;
        } else {
          showLabels = true;
        }
      } else {
        showLabels = !!showLabels;
      }

      return d3_byte_scale_tickFormat(scale.domain(), n, unit, showLabels);
    };

    scale.nice = function (/*count*/) {
      return this;
    };

    scale.copy = function () {
      return d3_byte_scale(linear.copy());
    };

    d3.rebind(scale, linear, 'invert', 'domain', 'range' /*, 'rangeRound', 'interpolate', 'clamp' */);

    return scale;
  }

  function d3_byte_scale_ticks(domain, m) {
    return d3.range.apply(d3, d3_byte_scale_tickRange(domain, m));
  }

  function d3_byte_scale_tickRange(domain, m) {
    if (m == null) {
      m = 8;
    }

    var extent = d3.extent(domain),
      span = extent[1] - extent[0],
      step = Math.pow(2, Math.floor(Math.log(span / m) / Math.LN2)),
      err = m / span * step;

    if (err <= 0.25) {
      step *= 8;
    } else if (err <= 0.5) {
      step *= 4;
    } else if (err <= 0.75) {
      step *= 2;
    }

    extent[0] = Math.ceil(extent[0] / step) * step;
    extent[1] = Math.floor(extent[1] / step) * step + step * 0.5;
    extent[2] = step;

    return extent;
  }

  function d3_byte_scale_tickFormat(domain, n, unit, showLabels) {
    var range, level, base, precision, label;

    range = d3_byte_scale_tickRange(domain, n);

    if ((level = d3_byte_scale_units.indexOf(unit)) === -1) {
      level = Math.floor(Math.log(range[1]) / Math.LN2 / 10 + 0.001);
      unit = d3_byte_scale_units[level];
    }

    base = Math.pow(1024, level);
    precision = -Math.floor(Math.log(range[2] / base) / Math.LN2 + 0.001);
    label = showLabels ? unit : '';

    return function(value) {
      // return d3.format(',.' + precision + 'f')(value / base) + label;
      return d3.format(',.0f')(value / base) + label;
    };
  }

  var d3_byte_scale_units = ['B', 'KB', 'MB', 'GB', 'TB'];
})(d3);