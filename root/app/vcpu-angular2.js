
var vcpu = angular.module('vcpu', ['d3'])
  .config(function($httpProvider) {  // Enable CORS for development purposes
    $httpProvider.defaults.useXDomain = true;
    delete $httpProvider.defaults.headers
      .common['X-Requested-With'];
  });



vcpu.controller('VcpuCtrl', function($scope, $http, $interval) {
  var vctrl = this;

  $interval(function() {
    $http.get('http://nydevsol10.dev.bloomberg.com:3000/vcpu/nydevsol10?content-type=application/json').
      then(function(response) {
        var kstat_data = response.data.body;
        var temp_array = [];
        var static_data = [
          [ {"idl": 93, "CPU": 0}, {"CPU": 1, "idl": 88}, {"CPU": 2, "idl": 94}, {"idl": 98, "CPU": 3},
            {"idl": 98, "CPU": 4 }, {"idl": 98, "CPU": 5}, {"idl": 99, "CPU": 6}, {"CPU": 7, "idl": 99} ],
          [ {"CPU": 8, "idl": 96}, {"idl": 94, "CPU": 9 }, {"CPU": 10, "idl": 88}, {"CPU": 11, "idl": 96},
            {"CPU": 12, "idl": 98}, {"CPU": 13, "idl": 99}, {"CPU": 14, "idl": 100}, {"idl": 99, "CPU": 15} ]
        ];
        // console.log(kstat_data);
        while (kstat_data.length > 0) {
          var core = kstat_data.splice(0,8);
          temp_array.push(core);
        }
        // console.log(temp_array);
        // $scope.cpu_data = static_data;
        $scope.cpu_data = temp_array;
      }, function(err) {
        throw err;
      });
  }, 1000);
});

vcpu.directive('vcpuGrid', ['d3Service', function(d3Service) {
    return {
      restrict: 'EA',
      scope:    {
        data:   "="
      },
      link: function(scope, element, attrs) {
        d3Service.d3().then(function(d3) {
          // d3 is the raw d3 object
          // Our d3 code will go here

          // This color scale maps different CPU utilization regions with mnemonic
          // colors to be displayed, so one can always have a sense of the current
          // load
          var colorScale = d3.scale.linear()
            .domain([0,1,49,50,74,75,89,90,99,100])
            .range(["gray","lime","lime","yellow","yellow","orange","orange",
              "red","red","fuchsia"]);

          var div = d3.select(element[0])
            .append("div")
            .style('border','2px solid purple');

          // Create a table for each locality Group / NUMA node
          var table = div
            .append("table");

          var header = table
            .append('tr')
            .append('th')
            .attr('colspan',8)
            .text("Locality Group 0");

          var headercols_row = table
            .append('tr');

          // TODO: Make this a selector
          headercols_row.append('th');
          headercols_row.append('th');
          headercols_row.append('th');
          headercols_row.append('th');
          headercols_row.append('th');
          headercols_row.append('th');
          headercols_row.append('th');
          headercols_row.append('th');

          headercols_row.selectAll('th')
            .append('div')
            .attr('class','cpuname')
            .text('CPU #');

          headercols_row.selectAll('th')
            .append('div')
            .attr('class','idle')
            .text('IDLE');

          headercols_row.selectAll('th')
            .append('div')
            .attr('class','user')
            .text('USER');

          headercols_row.selectAll('th')
            .append('div')
            .attr('class','sys')
            .text('SYS');

          var tbody = table
            .append("tbody");

          // watch for data changes and re-render
          scope.$watch('data', function(newVals, oldVals) {
            return scope.render(newVals);
          }, true);

          scope.render = function(data) {
            console.log("Entering render");
            //console.log(data);
            // our custom d3 code

            // If we don't get any data, return out of the element
            if (!data) return;

            // set up variables
            // var width = d3.select(element[0]).node().offsetWidth;

            // Create a table row for each core
            var tr = d3.select("table tbody").selectAll("tr")
              .data(data);

            // Create a table data entry for each strand
            var td = tr.selectAll("td")
              .data(function(d, i) { return d; })
              .style("color", function(d) { return colorScale(100 - d.idl); })
              .html(function(d) {
                return '<div class=cpuname>' + d.CPU  + '</div>' +
                  '<div class=idle>'    + d.idl  + '</div>'  +
                  '<div class="user">'  + d.usr  + '</div>'  +
                  '<div class="sys">'   + d.sys  + '</div>'
                  ; });

            tr = d3.select("table tbody").selectAll("tr")
              .data(data)
              .enter()
              .append("tr");

            td = tr.selectAll("td")
              .data(function(d, i) { return d; })
              .enter()
              .append("td")
              .style("color", function(d) { return colorScale(100 - d.idl); })
              .html(function(d) {
                return '<div class=cpuname>' + d.CPU  + '</div>' +
                  '<div class=idle>'    + d.idl  + '</div>'  +
                  '<div class="user">'  + d.usr  + '</div>'  +
                  '<div class="sys">'   + d.sys  + '</div>'
                  ; });
          }
        });
      }
    }
  }]
);
