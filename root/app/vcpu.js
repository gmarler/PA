/**
 * Created by gmarler on 9/2/2015.
 */

var cpu_data = [
  [ 0, 25, 50, 75, 85, 90, 95, 100 ],
  [ 0, 25, 50, 75, 85, 90, 95, 100 ],
  [ 0, 25, 50, 75, 85, 90, 95, 100 ],
  [ 0, 25, 50, 75, 85, 90, 95, 100 ],
  [ 0, 25, 50, 75, 85, 90, 95, 100 ],
  [ 0, 25, 50, 75, 85, 90, 95, 100 ],
  [ 0, 25, 50, 75, 85, 90, 95, 100 ],
  [ 0, 25, 50, 75, 85, 90, 95, 100 ]
];

var colorScale = d3.scale.linear()
  .domain([0,1,50,60,89,90,99,100])
  .range(["gray","lime","lime","yellow","yellow","red","red","fuchsia"]);

var tr = d3.select("table tbody").selectAll("tr")
  .data(cpu_data)
  .enter()
  .append("tr");

var td = tr.selectAll("td")
  .data(function(d, i) { return d; })
  .enter()
  .append("td")
  .style("background-color", function(d) { return colorScale(d); })
  .html(function(d) { return d; });

