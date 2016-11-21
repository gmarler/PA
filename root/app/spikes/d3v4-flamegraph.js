(function() {
  'use strict';

  function flameGraph() {
  }

  if (typeof module !== 'undefined' && module.exports) {
    module.exports = flameGraph;
  }
  else {
    d3.flameGraph = flameGraph;
  }
})();
