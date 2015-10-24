
var vcpu = angular.module('vcpu', ['d3'])
  .config(function($httpProvider) {  // Enable CORS for development purposes
    $httpProvider.defaults.useXDomain = true;
    delete $httpProvider.defaults.headers
      .common['X-Requested-With'];
  });



vcpu.controller('VcpuCtrl', function($scope, $http, $interval) {
  var vctrl = this;
  var gen = 0;
  var static_data = [
    [{"cores":[{"core":201457665,"cpus":[{"stats":{"usr":2,"sys":6,"idl":92},"cpu":0},{"stats":{"usr":4,"sys":9,"idl":87},"cpu":1},{"stats":{"usr":17,"sys":3,"idl":80},"cpu":2},{"stats":{"idl":98,"usr":0,"sys":1},"cpu":3},{"stats":{"idl":98,"sys":2,"usr":0},"cpu":4},{"cpu":5,"stats":{"idl":97,"usr":1,"sys":2}},{"cpu":6,"stats":{"sys":1,"usr":1,"idl":98}},{"cpu":7,"stats":{"idl":96,"usr":2,"sys":2}}]},{"cpus":[{"stats":{"sys":4,"usr":2,"idl":93},"cpu":8},{"cpu":9,"stats":{"usr":3,"sys":6,"idl":92}},{"cpu":10,"stats":{"idl":89,"sys":7,"usr":3}},{"stats":{"sys":2,"usr":2,"idl":96},"cpu":11},{"stats":{"idl":99,"usr":0,"sys":1},"cpu":12},{"cpu":13,"stats":{"usr":0,"sys":2,"idl":98}},{"stats":{"sys":1,"usr":1,"idl":99},"cpu":14},{"cpu":15,"stats":{"sys":1,"usr":1,"idl":98}}],"core":201654273},{"core":201850881,"cpus":[{"stats":{"sys":2,"usr":1,"idl":97},"cpu":16},{"cpu":17,"stats":{"idl":95,"sys":3,"usr":2}},{"stats":{"sys":3,"usr":3,"idl":94},"cpu":18},{"stats":{"usr":3,"sys":9,"idl":88},"cpu":19},{"stats":{"idl":97,"sys":2,"usr":1},"cpu":20},{"cpu":21,"stats":{"sys":13,"usr":0,"idl":87}},{"stats":{"idl":99,"usr":0,"sys":0},"cpu":22},{"stats":{"usr":1,"sys":1,"idl":99},"cpu":23}]},{"core":202047489,"cpus":[{"stats":{"idl":97,"sys":2,"usr":1},"cpu":24},{"stats":{"idl":95,"usr":1,"sys":4},"cpu":25},{"cpu":26,"stats":{"idl":96,"sys":2,"usr":2}},{"stats":{"idl":93,"usr":3,"sys":3},"cpu":27},{"stats":{"sys":8,"usr":6,"idl":86},"cpu":28},{"stats":{"idl":96,"usr":2,"sys":2},"cpu":29},{"cpu":30,"stats":{"idl":100,"usr":0,"sys":0}},{"cpu":31,"stats":{"sys":0,"usr":0,"idl":99}}]},{"cpus":[{"stats":{"idl":98,"usr":1,"sys":2},"cpu":32},{"cpu":33,"stats":{"usr":1,"sys":2,"idl":97}},{"cpu":34,"stats":{"sys":1,"usr":1,"idl":97}},{"cpu":35,"stats":{"idl":96,"usr":2,"sys":2}},{"cpu":36,"stats":{"idl":94,"usr":3,"sys":4}},{"cpu":37,"stats":{"sys":7,"usr":4,"idl":89}},{"cpu":38,"stats":{"idl":97,"usr":1,"sys":2}},{"stats":{"idl":99,"sys":0,"usr":0},"cpu":39}],"core":202244097},{"cpus":[{"stats":{"sys":2,"usr":0,"idl":98},"cpu":40},{"cpu":41,"stats":{"idl":98,"usr":1,"sys":2}},{"stats":{"usr":1,"sys":2,"idl":97},"cpu":42},{"stats":{"idl":93,"sys":4,"usr":3},"cpu":43},{"cpu":44,"stats":{"sys":0,"usr":0,"idl":100}},{"stats":{"usr":2,"sys":5,"idl":93},"cpu":45},{"cpu":46,"stats":{"usr":5,"sys":9,"idl":87}},{"cpu":47,"stats":{"idl":97,"usr":1,"sys":2}}],"core":202440705},{"core":202637313,"cpus":[{"stats":{"usr":1,"sys":2,"idl":97},"cpu":48},{"cpu":49,"stats":{"sys":1,"usr":0,"idl":99}},{"cpu":50,"stats":{"idl":99,"usr":0,"sys":0}},{"cpu":51,"stats":{"sys":1,"usr":1,"idl":99}},{"cpu":52,"stats":{"usr":2,"sys":3,"idl":95}},{"cpu":53,"stats":{"usr":3,"sys":3,"idl":94}},{"stats":{"usr":3,"sys":3,"idl":95},"cpu":54},{"stats":{"idl":89,"sys":7,"usr":4},"cpu":55}]},{"core":202833921,"cpus":[{"cpu":56,"stats":{"idl":87,"sys":9,"usr":4}},{"stats":{"sys":3,"usr":1,"idl":97},"cpu":57},{"cpu":58,"stats":{"idl":97,"sys":2,"usr":0}},{"stats":{"idl":100,"sys":0,"usr":0},"cpu":59},{"cpu":60,"stats":{"usr":1,"sys":2,"idl":97}},{"cpu":61,"stats":{"usr":1,"sys":3,"idl":96}},{"stats":{"idl":96,"sys":2,"usr":2},"cpu":62},{"cpu":63,"stats":{"idl":95,"sys":3,"usr":2}}]}],"LG":1},{"cores":[{"cpus":[{"stats":{"idl":95,"usr":2,"sys":3},"cpu":64},{"cpu":65,"stats":{"idl":89,"sys":9,"usr":3}},{"cpu":66,"stats":{"idl":97,"usr":1,"sys":2}},{"cpu":67,"stats":{"idl":100,"sys":0,"usr":0}},{"stats":{"idl":99,"usr":0,"sys":0},"cpu":68},{"cpu":69,"stats":{"idl":97,"usr":1,"sys":2}},{"cpu":70,"stats":{"idl":97,"usr":1,"sys":2}},{"cpu":71,"stats":{"idl":96,"sys":2,"usr":2}}],"core":203030529},{"core":203227137,"cpus":[{"cpu":72,"stats":{"idl":96,"sys":2,"usr":2}},{"cpu":73,"stats":{"idl":93,"sys":5,"usr":2}},{"stats":{"usr":2,"sys":6,"idl":91},"cpu":74},{"cpu":75,"stats":{"idl":98,"usr":1,"sys":2}},{"cpu":76,"stats":{"idl":100,"sys":0,"usr":0}},{"stats":{"idl":99,"sys":1,"usr":0},"cpu":77},{"stats":{"idl":97,"usr":1,"sys":2},"cpu":78},{"stats":{"sys":1,"usr":1,"idl":97},"cpu":79}]},{"core":203423745,"cpus":[{"stats":{"idl":97,"usr":1,"sys":1},"cpu":80},{"cpu":81,"stats":{"usr":2,"sys":4,"idl":94}},{"stats":{"usr":2,"sys":3,"idl":95},"cpu":82},{"cpu":83,"stats":{"usr":3,"sys":6,"idl":91}},{"stats":{"idl":98,"sys":2,"usr":1},"cpu":84},{"cpu":85,"stats":{"idl":99,"usr":0,"sys":1}},{"cpu":86,"stats":{"idl":97,"usr":0,"sys":3}},{"stats":{"idl":98,"usr":1,"sys":1},"cpu":87}]},{"core":203620353,"cpus":[{"cpu":88,"stats":{"idl":95,"sys":3,"usr":2}},{"cpu":89,"stats":{"usr":0,"sys":0,"idl":100}},{"cpu":90,"stats":{"sys":3,"usr":2,"idl":96}},{"cpu":91,"stats":{"idl":95,"usr":2,"sys":3}},{"stats":{"sys":7,"usr":3,"idl":90},"cpu":92},{"stats":{"idl":97,"sys":2,"usr":1},"cpu":93},{"cpu":94,"stats":{"idl":98,"sys":2,"usr":0}},{"stats":{"usr":1,"sys":1,"idl":99},"cpu":95}]},{"core":203816961,"cpus":[{"cpu":96,"stats":{"sys":1,"usr":0,"idl":99}},{"stats":{"usr":0,"sys":1,"idl":98},"cpu":97},{"cpu":98,"stats":{"usr":1,"sys":2,"idl":96}},{"stats":{"sys":2,"usr":2,"idl":96},"cpu":99},{"stats":{"sys":6,"usr":2,"idl":92},"cpu":100},{"cpu":101,"stats":{"idl":88,"usr":3,"sys":9}},{"cpu":102,"stats":{"idl":96,"usr":1,"sys":2}},{"stats":{"idl":100,"usr":0,"sys":0},"cpu":103}]},{"core":204013569,"cpus":[{"cpu":104,"stats":{"idl":100,"usr":0,"sys":0}},{"cpu":105,"stats":{"usr":0,"sys":2,"idl":98}},{"stats":{"idl":96,"sys":3,"usr":1},"cpu":106},{"stats":{"sys":1,"usr":1,"idl":98},"cpu":107},{"stats":{"usr":2,"sys":2,"idl":97},"cpu":108},{"cpu":109,"stats":{"usr":2,"sys":6,"idl":92}},{"stats":{"idl":91,"usr":2,"sys":7},"cpu":110},{"stats":{"sys":1,"usr":1,"idl":99},"cpu":111}]},{"core":204210177,"cpus":[{"stats":{"idl":97,"usr":1,"sys":2},"cpu":112},{"stats":{"sys":2,"usr":0,"idl":98},"cpu":113},{"stats":{"sys":2,"usr":0,"idl":98},"cpu":114},{"cpu":115,"stats":{"usr":1,"sys":1,"idl":98}},{"stats":{"sys":3,"usr":1,"idl":96},"cpu":116},{"cpu":117,"stats":{"sys":3,"usr":1,"idl":96}},{"stats":{"idl":94,"usr":2,"sys":3},"cpu":118},{"stats":{"idl":91,"usr":3,"sys":6},"cpu":119}]},{"core":204406785,"cpus":[{"cpu":120,"stats":{"usr":3,"sys":9,"idl":89}},{"stats":{"usr":1,"sys":2,"idl":97},"cpu":121},{"cpu":122,"stats":{"idl":98,"sys":2,"usr":0}},{"stats":{"idl":100,"sys":0,"usr":0},"cpu":123},{"cpu":124,"stats":{"usr":1,"sys":1,"idl":99}},{"stats":{"sys":4,"usr":1,"idl":95},"cpu":125},{"stats":{"idl":95,"sys":3,"usr":2},"cpu":126},{"cpu":127,"stats":{"usr":2,"sys":3,"idl":95}}]}],"LG":2},{"cores":[{"core":204603393,"cpus":[{"cpu":128,"stats":{"idl":99,"usr":0,"sys":1}},{"stats":{"idl":96,"usr":0,"sys":4},"cpu":129},{"stats":{"usr":0,"sys":2,"idl":98},"cpu":130},{"stats":{"idl":99,"usr":0,"sys":1},"cpu":131},{"cpu":132,"stats":{"idl":99,"usr":0,"sys":1}},{"stats":{"idl":100,"sys":0,"usr":0},"cpu":133},{"stats":{"usr":0,"sys":2,"idl":98},"cpu":134},{"cpu":135,"stats":{"idl":98,"sys":2,"usr":0}}]},{"cpus":[{"cpu":136,"stats":{"sys":0,"usr":0,"idl":100}},{"stats":{"idl":99,"usr":0,"sys":1},"cpu":137},{"cpu":138,"stats":{"idl":92,"sys":8,"usr":0}},{"cpu":139,"stats":{"idl":99,"usr":0,"sys":1}},{"stats":{"sys":0,"usr":0,"idl":100},"cpu":140},{"cpu":141,"stats":{"idl":100,"sys":0,"usr":0}},{"cpu":142,"stats":{"idl":99,"usr":0,"sys":1}},{"cpu":143,"stats":{"idl":99,"sys":1,"usr":0}}],"core":204800001},{"core":204996609,"cpus":[{"cpu":144,"stats":{"idl":100,"sys":0,"usr":0}},{"stats":{"usr":0,"sys":0,"idl":100},"cpu":145},{"cpu":146,"stats":{"idl":98,"sys":2,"usr":0}},{"cpu":147,"stats":{"sys":6,"usr":0,"idl":94}},{"stats":{"sys":1,"usr":0,"idl":99},"cpu":148},{"stats":{"usr":0,"sys":0,"idl":100},"cpu":149},{"stats":{"sys":1,"usr":0,"idl":99},"cpu":150},{"cpu":151,"stats":{"sys":2,"usr":0,"idl":98}}]},{"cpus":[{"cpu":152,"stats":{"idl":100,"usr":0,"sys":0}},{"stats":{"sys":1,"usr":0,"idl":99},"cpu":153},{"stats":{"idl":99,"sys":1,"usr":0},"cpu":154},{"cpu":155,"stats":{"idl":98,"sys":1,"usr":0}},{"cpu":156,"stats":{"sys":5,"usr":0,"idl":95}},{"stats":{"usr":0,"sys":2,"idl":98},"cpu":157},{"cpu":158,"stats":{"usr":0,"sys":2,"idl":98}},{"stats":{"sys":1,"usr":0,"idl":99},"cpu":159}],"core":205193217},{"core":205389825,"cpus":[{"stats":{"usr":0,"sys":0,"idl":100},"cpu":160},{"stats":{"idl":100,"sys":0,"usr":0},"cpu":161},{"stats":{"idl":99,"sys":1,"usr":0},"cpu":162},{"cpu":163,"stats":{"usr":0,"sys":2,"idl":98}},{"cpu":164,"stats":{"idl":98,"usr":0,"sys":2}},{"cpu":165,"stats":{"idl":94,"sys":6,"usr":0}},{"stats":{"idl":99,"sys":1,"usr":0},"cpu":166},{"cpu":167,"stats":{"idl":99,"sys":1,"usr":0}}]},{"cpus":[{"cpu":168,"stats":{"idl":100,"usr":0,"sys":0}},{"cpu":169,"stats":{"usr":0,"sys":0,"idl":100}},{"stats":{"idl":99,"usr":0,"sys":1},"cpu":170},{"cpu":171,"stats":{"usr":0,"sys":2,"idl":98}},{"stats":{"usr":0,"sys":0,"idl":100},"cpu":172},{"cpu":173,"stats":{"idl":99,"sys":1,"usr":0}},{"cpu":174,"stats":{"idl":94,"sys":6,"usr":0}},{"stats":{"idl":98,"sys":2,"usr":0},"cpu":175}],"core":205586433},{"core":205783041,"cpus":[{"cpu":176,"stats":{"sys":0,"usr":0,"idl":100}},{"stats":{"sys":0,"usr":0,"idl":100},"cpu":177},{"cpu":178,"stats":{"idl":99,"sys":1,"usr":0}},{"cpu":179,"stats":{"usr":0,"sys":2,"idl":98}},{"cpu":180,"stats":{"idl":100,"usr":0,"sys":0}},{"cpu":181,"stats":{"idl":100,"sys":0,"usr":0}},{"stats":{"idl":98,"sys":2,"usr":0},"cpu":182},{"stats":{"usr":0,"sys":5,"idl":95},"cpu":183}]},{"cpus":[{"cpu":184,"stats":{"sys":4,"usr":20,"idl":76}},{"cpu":185,"stats":{"sys":2,"usr":0,"idl":98}},{"cpu":186,"stats":{"idl":99,"sys":1,"usr":0}},{"stats":{"idl":99,"usr":0,"sys":1},"cpu":187},{"stats":{"idl":100,"usr":0,"sys":0},"cpu":188},{"stats":{"idl":100,"sys":0,"usr":0},"cpu":189},{"cpu":190,"stats":{"idl":99,"usr":0,"sys":1}},{"cpu":191,"stats":{"idl":97,"usr":0,"sys":2}}],"core":205979649}],"LG":3},{"LG":4,"cores":[{"core":206176257,"cpus":[{"cpu":192,"stats":{"idl":98,"usr":0,"sys":2}},{"cpu":193,"stats":{"idl":95,"sys":5,"usr":0}},{"cpu":194,"stats":{"idl":99,"sys":1,"usr":0}},{"cpu":195,"stats":{"usr":0,"sys":2,"idl":98}},{"stats":{"idl":99,"usr":0,"sys":1},"cpu":196},{"cpu":197,"stats":{"usr":0,"sys":0,"idl":100}},{"cpu":198,"stats":{"sys":0,"usr":0,"idl":100}},{"stats":{"idl":99,"sys":1,"usr":0},"cpu":199}]},{"cpus":[{"stats":{"usr":0,"sys":2,"idl":98},"cpu":200},{"cpu":201,"stats":{"usr":0,"sys":1,"idl":99}},{"cpu":202,"stats":{"idl":95,"sys":5,"usr":0}},{"cpu":203,"stats":{"idl":99,"usr":0,"sys":1}},{"cpu":204,"stats":{"idl":98,"sys":2,"usr":0}},{"stats":{"idl":100,"sys":0,"usr":0},"cpu":205},{"stats":{"idl":100,"sys":0,"usr":0},"cpu":206},{"cpu":207,"stats":{"sys":1,"usr":0,"idl":99}}],"core":206372865},{"core":206569473,"cpus":[{"stats":{"idl":99,"sys":1,"usr":0},"cpu":208},{"stats":{"usr":0,"sys":0,"idl":100},"cpu":209},{"cpu":210,"stats":{"sys":1,"usr":0,"idl":99}},{"cpu":211,"stats":{"sys":6,"usr":0,"idl":94}},{"stats":{"sys":3,"usr":0,"idl":97},"cpu":212},{"cpu":213,"stats":{"idl":100,"usr":0,"sys":0}},{"cpu":214,"stats":{"idl":100,"usr":0,"sys":0}},{"stats":{"usr":0,"sys":2,"idl":98},"cpu":215}]},{"core":206766081,"cpus":[{"stats":{"sys":1,"usr":0,"idl":99},"cpu":216},{"stats":{"usr":0,"sys":0,"idl":100},"cpu":217},{"stats":{"sys":1,"usr":0,"idl":99},"cpu":218},{"stats":{"sys":2,"usr":0,"idl":98},"cpu":219},{"stats":{"idl":96,"usr":0,"sys":4},"cpu":220},{"cpu":221,"stats":{"usr":0,"sys":1,"idl":99}},{"stats":{"idl":100,"sys":0,"usr":0},"cpu":222},{"stats":{"idl":99,"usr":0,"sys":1},"cpu":223}]},{"cpus":[{"stats":{"idl":98,"sys":2,"usr":0},"cpu":224},{"stats":{"idl":100,"usr":0,"sys":0},"cpu":225},{"cpu":226,"stats":{"idl":100,"usr":0,"sys":0}},{"stats":{"idl":99,"usr":0,"sys":1},"cpu":227},{"cpu":228,"stats":{"usr":0,"sys":2,"idl":97}},{"cpu":229,"stats":{"sys":4,"usr":0,"idl":96}},{"cpu":230,"stats":{"sys":1,"usr":0,"idl":99}},{"cpu":231,"stats":{"idl":99,"usr":0,"sys":1}}],"core":206962689},{"core":207159297,"cpus":[{"cpu":232,"stats":{"usr":0,"sys":1,"idl":99}},{"cpu":233,"stats":{"idl":99,"sys":1,"usr":0}},{"stats":{"usr":0,"sys":1,"idl":99},"cpu":234},{"cpu":235,"stats":{"usr":0,"sys":1,"idl":99}},{"stats":{"idl":99,"usr":0,"sys":1},"cpu":236},{"stats":{"usr":0,"sys":1,"idl":99},"cpu":237},{"stats":{"usr":0,"sys":7,"idl":93},"cpu":238},{"stats":{"idl":99,"usr":0,"sys":1},"cpu":239}]},{"cpus":[{"stats":{"usr":0,"sys":1,"idl":99},"cpu":240},{"stats":{"idl":100,"usr":0,"sys":0},"cpu":241},{"cpu":242,"stats":{"idl":100,"usr":0,"sys":0}},{"stats":{"idl":99,"usr":0,"sys":1},"cpu":243},{"stats":{"idl":98,"sys":2,"usr":0},"cpu":244},{"stats":{"sys":1,"usr":0,"idl":99},"cpu":245},{"cpu":246,"stats":{"idl":99,"usr":0,"sys":1}},{"stats":{"idl":96,"usr":0,"sys":4},"cpu":247}],"core":207355905},{"core":207552513,"cpus":[{"stats":{"idl":95,"sys":5,"usr":0},"cpu":248},{"cpu":249,"stats":{"sys":1,"usr":0,"idl":99}},{"stats":{"idl":100,"usr":0,"sys":0},"cpu":250},{"cpu":251,"stats":{"idl":99,"sys":1,"usr":0}},{"cpu":252,"stats":{"usr":0,"sys":2,"idl":98}},{"cpu":253,"stats":{"sys":0,"usr":0,"idl":100}},{"stats":{"usr":0,"sys":0,"idl":100},"cpu":254},{"cpu":255,"stats":{"idl":98,"usr":0,"sys":2}}]}]}],
    [{"cores":[{"core":201457665,"cpus":[{"cpu":0,"stats":{"sys":8,"usr":3,"idl":89}},{"cpu":1,"stats":{"sys":9,"usr":4,"idl":87}},{"cpu":2,"stats":{"idl":96,"sys":3,"usr":1}},{"cpu":3,"stats":{"idl":98,"usr":0,"sys":2}},{"cpu":4,"stats":{"idl":97,"sys":3,"usr":0}},{"cpu":5,"stats":{"idl":97,"usr":1,"sys":2}},{"cpu":6,"stats":{"idl":97,"usr":1,"sys":2}},{"cpu":7,"stats":{"usr":2,"sys":3,"idl":95}}]},{"cpus":[{"cpu":8,"stats":{"usr":2,"sys":4,"idl":94}},{"cpu":9,"stats":{"idl":89,"sys":7,"usr":4}},{"cpu":10,"stats":{"idl":91,"usr":4,"sys":5}},{"stats":{"idl":96,"usr":1,"sys":3},"cpu":11},{"cpu":12,"stats":{"sys":2,"usr":0,"idl":98}},{"cpu":13,"stats":{"idl":98,"usr":0,"sys":2}},{"cpu":14,"stats":{"usr":0,"sys":1,"idl":98}},{"stats":{"idl":98,"usr":1,"sys":2},"cpu":15}],"core":201654273},{"core":201850881,"cpus":[{"stats":{"idl":95,"usr":1,"sys":3},"cpu":16},{"cpu":17,"stats":{"usr":2,"sys":4,"idl":94}},{"stats":{"idl":94,"sys":3,"usr":3},"cpu":18},{"cpu":19,"stats":{"idl":86,"usr":7,"sys":7}},{"stats":{"sys":2,"usr":1,"idl":97},"cpu":20},{"stats":{"usr":0,"sys":2,"idl":98},"cpu":21},{"stats":{"usr":0,"sys":1,"idl":99},"cpu":22},{"cpu":23,"stats":{"usr":1,"sys":2,"idl":97}}]},{"core":202047489,"cpus":[{"cpu":24,"stats":{"idl":98,"sys":2,"usr":1}},{"stats":{"sys":3,"usr":1,"idl":96},"cpu":25},{"stats":{"idl":96,"sys":3,"usr":2},"cpu":26},{"stats":{"sys":4,"usr":3,"idl":93},"cpu":27},{"stats":{"idl":85,"sys":10,"usr":4},"cpu":28},{"cpu":29,"stats":{"idl":95,"sys":5,"usr":1}},{"cpu":30,"stats":{"usr":0,"sys":1,"idl":99}},{"stats":{"idl":99,"sys":1,"usr":0},"cpu":31}]},{"cpus":[{"cpu":32,"stats":{"sys":2,"usr":0,"idl":98}},{"cpu":33,"stats":{"idl":97,"sys":2,"usr":1}},{"stats":{"sys":2,"usr":1,"idl":97},"cpu":34},{"cpu":35,"stats":{"idl":95,"sys":3,"usr":2}},{"stats":{"idl":91,"usr":3,"sys":6},"cpu":36},{"stats":{"idl":87,"usr":5,"sys":8},"cpu":37},{"cpu":38,"stats":{"usr":1,"sys":2,"idl":97}},{"cpu":39,"stats":{"sys":2,"usr":0,"idl":98}}],"core":202244097},{"cpus":[{"stats":{"idl":97,"usr":0,"sys":3},"cpu":40},{"cpu":41,"stats":{"usr":0,"sys":2,"idl":98}},{"cpu":42,"stats":{"usr":1,"sys":1,"idl":98}},{"cpu":43,"stats":{"idl":97,"sys":2,"usr":1}},{"stats":{"idl":95,"usr":2,"sys":3},"cpu":44},{"stats":{"usr":3,"sys":5,"idl":92},"cpu":45},{"stats":{"idl":89,"sys":7,"usr":4},"cpu":46},{"cpu":47,"stats":{"idl":95,"usr":1,"sys":3}}],"core":202440705},{"cpus":[{"cpu":48,"stats":{"idl":96,"sys":3,"usr":1}},{"stats":{"idl":98,"usr":0,"sys":1},"cpu":49},{"cpu":50,"stats":{"idl":99,"sys":1,"usr":0}},{"stats":{"idl":97,"sys":2,"usr":0},"cpu":51},{"stats":{"idl":95,"usr":1,"sys":4},"cpu":52},{"stats":{"usr":3,"sys":4,"idl":93},"cpu":53},{"cpu":54,"stats":{"sys":5,"usr":3,"idl":92}},{"stats":{"usr":19,"sys":8,"idl":72},"cpu":55}],"core":202637313},{"cpus":[{"cpu":56,"stats":{"usr":4,"sys":8,"idl":88}},{"cpu":57,"stats":{"idl":97,"sys":2,"usr":1}},{"stats":{"sys":4,"usr":1,"idl":95},"cpu":58},{"cpu":59,"stats":{"idl":99,"sys":1,"usr":0}},{"cpu":60,"stats":{"usr":1,"sys":2,"idl":97}},{"cpu":61,"stats":{"idl":95,"usr":1,"sys":4}},{"stats":{"idl":95,"usr":2,"sys":3},"cpu":62},{"stats":{"sys":4,"usr":3,"idl":93},"cpu":63}],"core":202833921}],"LG":1},{"cores":[{"cpus":[{"cpu":64,"stats":{"idl":94,"sys":4,"usr":2}},{"stats":{"idl":91,"usr":3,"sys":7},"cpu":65},{"cpu":66,"stats":{"sys":3,"usr":1,"idl":96}},{"cpu":67,"stats":{"idl":99,"usr":0,"sys":1}},{"cpu":68,"stats":{"idl":98,"sys":1,"usr":0}},{"cpu":69,"stats":{"idl":96,"usr":1,"sys":4}},{"stats":{"idl":97,"sys":2,"usr":1},"cpu":70},{"stats":{"idl":96,"usr":2,"sys":3},"cpu":71}],"core":203030529},{"cpus":[{"stats":{"idl":96,"usr":2,"sys":2},"cpu":72},{"cpu":73,"stats":{"idl":93,"sys":5,"usr":2}},{"stats":{"idl":90,"sys":8,"usr":3},"cpu":74},{"stats":{"sys":2,"usr":1,"idl":97},"cpu":75},{"stats":{"idl":99,"sys":1,"usr":0},"cpu":76},{"stats":{"sys":3,"usr":0,"idl":97},"cpu":77},{"stats":{"usr":1,"sys":2,"idl":98},"cpu":78},{"cpu":79,"stats":{"usr":1,"sys":2,"idl":97}}],"core":203227137},{"core":203423745,"cpus":[{"stats":{"idl":97,"usr":1,"sys":2},"cpu":80},{"cpu":81,"stats":{"usr":2,"sys":3,"idl":95}},{"stats":{"sys":5,"usr":2,"idl":93},"cpu":82},{"stats":{"idl":88,"usr":3,"sys":9},"cpu":83},{"cpu":84,"stats":{"sys":3,"usr":1,"idl":96}},{"cpu":85,"stats":{"idl":99,"usr":0,"sys":1}},{"stats":{"idl":97,"sys":2,"usr":0},"cpu":86},{"stats":{"sys":1,"usr":1,"idl":98},"cpu":87}]},{"cpus":[{"cpu":88,"stats":{"idl":97,"sys":3,"usr":1}},{"stats":{"usr":1,"sys":3,"idl":96},"cpu":89},{"cpu":90,"stats":{"idl":95,"sys":3,"usr":2}},{"stats":{"sys":3,"usr":2,"idl":94},"cpu":91},{"stats":{"idl":92,"sys":5,"usr":3},"cpu":92},{"stats":{"idl":96,"sys":3,"usr":0},"cpu":93},{"cpu":94,"stats":{"idl":96,"sys":4,"usr":0}},{"cpu":95,"stats":{"usr":0,"sys":2,"idl":98}}],"core":203620353},{"core":203816961,"cpus":[{"cpu":96,"stats":{"idl":98,"sys":2,"usr":0}},{"stats":{"sys":2,"usr":0,"idl":97},"cpu":97},{"cpu":98,"stats":{"idl":95,"sys":4,"usr":1}},{"cpu":99,"stats":{"sys":3,"usr":2,"idl":96}},{"stats":{"sys":3,"usr":2,"idl":95},"cpu":100},{"cpu":101,"stats":{"sys":12,"usr":3,"idl":85}},{"cpu":102,"stats":{"usr":1,"sys":4,"idl":95}},{"cpu":103,"stats":{"idl":99,"sys":1,"usr":0}}]},{"core":204013569,"cpus":[{"cpu":104,"stats":{"sys":1,"usr":0,"idl":99}},{"stats":{"sys":2,"usr":0,"idl":98},"cpu":105},{"cpu":106,"stats":{"idl":97,"usr":0,"sys":2}},{"stats":{"idl":97,"sys":2,"usr":1},"cpu":107},{"stats":{"idl":95,"sys":3,"usr":2},"cpu":108},{"cpu":109,"stats":{"sys":8,"usr":2,"idl":90}},{"stats":{"sys":8,"usr":2,"idl":90},"cpu":110},{"stats":{"sys":4,"usr":1,"idl":95},"cpu":111}]},{"core":204210177,"cpus":[{"cpu":112,"stats":{"sys":2,"usr":1,"idl":97}},{"stats":{"idl":97,"usr":0,"sys":2},"cpu":113},{"stats":{"idl":96,"usr":1,"sys":3},"cpu":114},{"cpu":115,"stats":{"sys":2,"usr":1,"idl":97}},{"stats":{"idl":98,"usr":1,"sys":1},"cpu":116},{"cpu":117,"stats":{"idl":93,"usr":2,"sys":5}},{"stats":{"idl":93,"sys":5,"usr":2},"cpu":118},{"stats":{"sys":8,"usr":3,"idl":89},"cpu":119}]},{"core":204406785,"cpus":[{"stats":{"sys":7,"usr":3,"idl":91},"cpu":120},{"cpu":121,"stats":{"idl":97,"usr":1,"sys":2}},{"cpu":122,"stats":{"idl":98,"sys":2,"usr":0}},{"cpu":123,"stats":{"idl":99,"sys":1,"usr":0}},{"cpu":124,"stats":{"sys":2,"usr":1,"idl":97}},{"cpu":125,"stats":{"sys":5,"usr":1,"idl":94}},{"stats":{"sys":4,"usr":2,"idl":94},"cpu":126},{"cpu":127,"stats":{"sys":3,"usr":2,"idl":94}}]}],"LG":2},{"LG":3,"cores":[{"cpus":[{"stats":{"usr":0,"sys":3,"idl":97},"cpu":128},{"cpu":129,"stats":{"sys":5,"usr":0,"idl":95}},{"cpu":130,"stats":{"idl":96,"sys":4,"usr":0}},{"cpu":131,"stats":{"sys":1,"usr":0,"idl":99}},{"stats":{"sys":1,"usr":0,"idl":99},"cpu":132},{"cpu":133,"stats":{"idl":100,"usr":0,"sys":0}},{"stats":{"idl":99,"usr":0,"sys":1},"cpu":134},{"cpu":135,"stats":{"idl":99,"usr":0,"sys":1}}],"core":204603393},{"cpus":[{"stats":{"idl":99,"sys":1,"usr":0},"cpu":136},{"cpu":137,"stats":{"idl":98,"usr":0,"sys":2}},{"stats":{"usr":0,"sys":6,"idl":94},"cpu":138},{"stats":{"sys":3,"usr":0,"idl":97},"cpu":139},{"stats":{"idl":99,"usr":0,"sys":1},"cpu":140},{"stats":{"idl":98,"usr":0,"sys":2},"cpu":141},{"cpu":142,"stats":{"usr":0,"sys":2,"idl":98}},{"stats":{"sys":2,"usr":0,"idl":98},"cpu":143}],"core":204800001},{"cpus":[{"cpu":144,"stats":{"usr":0,"sys":0,"idl":99}},{"stats":{"sys":2,"usr":0,"idl":98},"cpu":145},{"stats":{"idl":97,"sys":3,"usr":0},"cpu":146},{"cpu":147,"stats":{"usr":0,"sys":6,"idl":94}},{"cpu":148,"stats":{"sys":3,"usr":0,"idl":97}},{"cpu":149,"stats":{"usr":0,"sys":1,"idl":99}},{"cpu":150,"stats":{"usr":0,"sys":2,"idl":98}},{"stats":{"usr":0,"sys":1,"idl":99},"cpu":151}],"core":204996609},{"core":205193217,"cpus":[{"cpu":152,"stats":{"idl":99,"sys":1,"usr":0}},{"cpu":153,"stats":{"usr":0,"sys":1,"idl":99}},{"stats":{"usr":0,"sys":3,"idl":97},"cpu":154},{"cpu":155,"stats":{"idl":98,"usr":0,"sys":2}},{"stats":{"sys":6,"usr":0,"idl":94},"cpu":156},{"cpu":157,"stats":{"sys":1,"usr":0,"idl":99}},{"cpu":158,"stats":{"sys":1,"usr":0,"idl":99}},{"stats":{"sys":2,"usr":0,"idl":98},"cpu":159}]},{"cpus":[{"stats":{"usr":0,"sys":1,"idl":99},"cpu":160},{"stats":{"usr":0,"sys":0,"idl":100},"cpu":161},{"stats":{"sys":2,"usr":0,"idl":98},"cpu":162},{"stats":{"sys":2,"usr":0,"idl":98},"cpu":163},{"stats":{"idl":98,"sys":2,"usr":0},"cpu":164},{"stats":{"sys":7,"usr":0,"idl":93},"cpu":165},{"cpu":166,"stats":{"sys":3,"usr":0,"idl":97}},{"stats":{"sys":2,"usr":0,"idl":98},"cpu":167}],"core":205389825},{"core":205586433,"cpus":[{"stats":{"idl":100,"sys":0,"usr":0},"cpu":168},{"stats":{"usr":0,"sys":1,"idl":99},"cpu":169},{"cpu":170,"stats":{"sys":2,"usr":0,"idl":98}},{"cpu":171,"stats":{"sys":2,"usr":0,"idl":98}},{"cpu":172,"stats":{"usr":18,"sys":2,"idl":81}},{"stats":{"idl":99,"usr":0,"sys":1},"cpu":173},{"cpu":174,"stats":{"idl":95,"sys":5,"usr":0}},{"stats":{"usr":1,"sys":6,"idl":94},"cpu":175}]},{"core":205783041,"cpus":[{"stats":{"idl":97,"sys":3,"usr":0},"cpu":176},{"cpu":177,"stats":{"sys":1,"usr":0,"idl":99}},{"stats":{"sys":1,"usr":0,"idl":99},"cpu":178},{"cpu":179,"stats":{"usr":0,"sys":2,"idl":98}},{"cpu":180,"stats":{"sys":1,"usr":0,"idl":99}},{"stats":{"idl":99,"usr":0,"sys":1},"cpu":181},{"cpu":182,"stats":{"idl":97,"usr":0,"sys":3}},{"cpu":183,"stats":{"idl":93,"sys":7,"usr":0}}]},{"cpus":[{"stats":{"idl":91,"sys":7,"usr":2},"cpu":184},{"cpu":185,"stats":{"idl":97,"sys":3,"usr":0}},{"cpu":186,"stats":{"idl":99,"sys":1,"usr":0}},{"cpu":187,"stats":{"idl":97,"usr":0,"sys":3}},{"stats":{"idl":99,"usr":0,"sys":1},"cpu":188},{"stats":{"sys":1,"usr":0,"idl":99},"cpu":189},{"stats":{"idl":98,"usr":0,"sys":2},"cpu":190},{"stats":{"idl":98,"sys":2,"usr":0},"cpu":191}],"core":205979649}]},{"LG":4,"cores":[{"core":206176257,"cpus":[{"cpu":192,"stats":{"sys":3,"usr":0,"idl":97}},{"stats":{"sys":4,"usr":0,"idl":96},"cpu":193},{"stats":{"sys":2,"usr":0,"idl":98},"cpu":194},{"stats":{"idl":99,"sys":1,"usr":0},"cpu":195},{"cpu":196,"stats":{"idl":97,"usr":0,"sys":2}},{"cpu":197,"stats":{"idl":99,"sys":1,"usr":0}},{"cpu":198,"stats":{"usr":0,"sys":1,"idl":99}},{"cpu":199,"stats":{"idl":97,"sys":3,"usr":0}}]},{"core":206372865,"cpus":[{"cpu":200,"stats":{"idl":99,"sys":1,"usr":0}},{"stats":{"sys":2,"usr":0,"idl":98},"cpu":201},{"stats":{"idl":92,"usr":0,"sys":8},"cpu":202},{"stats":{"sys":3,"usr":0,"idl":97},"cpu":203},{"cpu":204,"stats":{"idl":98,"sys":2,"usr":0}},{"stats":{"idl":99,"sys":1,"usr":0},"cpu":205},{"cpu":206,"stats":{"idl":99,"usr":0,"sys":1}},{"cpu":207,"stats":{"idl":99,"sys":1,"usr":0}}]},{"cpus":[{"stats":{"sys":2,"usr":0,"idl":98},"cpu":208},{"cpu":209,"stats":{"sys":1,"usr":0,"idl":99}},{"cpu":210,"stats":{"usr":0,"sys":2,"idl":98}},{"stats":{"sys":6,"usr":0,"idl":94},"cpu":211},{"stats":{"idl":97,"sys":3,"usr":0},"cpu":212},{"stats":{"usr":0,"sys":1,"idl":99},"cpu":213},{"stats":{"usr":0,"sys":1,"idl":99},"cpu":214},{"stats":{"idl":98,"sys":2,"usr":0},"cpu":215}],"core":206569473},{"cpus":[{"cpu":216,"stats":{"idl":98,"sys":2,"usr":0}},{"stats":{"usr":0,"sys":2,"idl":98},"cpu":217},{"cpu":218,"stats":{"usr":0,"sys":1,"idl":99}},{"stats":{"idl":96,"usr":0,"sys":4},"cpu":219},{"cpu":220,"stats":{"sys":5,"usr":0,"idl":95}},{"cpu":221,"stats":{"idl":98,"sys":2,"usr":0}},{"stats":{"sys":1,"usr":0,"idl":99},"cpu":222},{"stats":{"idl":98,"usr":0,"sys":2},"cpu":223}],"core":206766081},{"core":206962689,"cpus":[{"stats":{"idl":97,"usr":0,"sys":3},"cpu":224},{"cpu":225,"stats":{"idl":99,"usr":0,"sys":1}},{"stats":{"idl":99,"usr":0,"sys":1},"cpu":226},{"cpu":227,"stats":{"idl":98,"sys":2,"usr":0}},{"stats":{"idl":98,"sys":2,"usr":0},"cpu":228},{"cpu":229,"stats":{"usr":0,"sys":5,"idl":95}},{"stats":{"idl":97,"usr":0,"sys":3},"cpu":230},{"stats":{"sys":3,"usr":0,"idl":97},"cpu":231}]},{"core":207159297,"cpus":[{"stats":{"sys":1,"usr":0,"idl":99},"cpu":232},{"stats":{"idl":99,"usr":0,"sys":1},"cpu":233},{"cpu":234,"stats":{"idl":99,"sys":1,"usr":0}},{"stats":{"idl":98,"usr":0,"sys":2},"cpu":235},{"cpu":236,"stats":{"idl":96,"sys":4,"usr":0}},{"cpu":237,"stats":{"idl":98,"sys":2,"usr":0}},{"cpu":238,"stats":{"idl":94,"sys":6,"usr":0}},{"cpu":239,"stats":{"idl":97,"sys":3,"usr":0}}]},{"core":207355905,"cpus":[{"cpu":240,"stats":{"sys":3,"usr":0,"idl":97}},{"cpu":241,"stats":{"usr":0,"sys":1,"idl":99}},{"stats":{"usr":0,"sys":1,"idl":99},"cpu":242},{"cpu":243,"stats":{"usr":0,"sys":3,"idl":97}},{"stats":{"usr":0,"sys":2,"idl":98},"cpu":244},{"stats":{"sys":1,"usr":0,"idl":99},"cpu":245},{"cpu":246,"stats":{"idl":98,"sys":2,"usr":0}},{"stats":{"usr":0,"sys":7,"idl":93},"cpu":247}]},{"cpus":[{"cpu":248,"stats":{"idl":95,"sys":5,"usr":0}},{"cpu":249,"stats":{"idl":98,"sys":2,"usr":0}},{"stats":{"idl":99,"usr":0,"sys":1},"cpu":250},{"stats":{"sys":1,"usr":0,"idl":99},"cpu":251},{"stats":{"usr":0,"sys":1,"idl":99},"cpu":252},{"stats":{"idl":99,"usr":0,"sys":1},"cpu":253},{"cpu":254,"stats":{"idl":99,"sys":1,"usr":0}},{"cpu":255,"stats":{"idl":96,"usr":0,"sys":4}}],"core":207552513}]}]
  ];


  $interval(function() {
    //gen = gen ^ 1;
    //var fake_kstat_data = static_data[gen];
    //var temp_array = [];
    //
    //for (i = 0; i < fake_kstat_data.length; i++) {
    //  var fdata = fake_kstat_data[i];
    //  temp_array.push(fdata);
    //}
    //
    //$scope.cpu_data = temp_array;

    $http.get('http://nydevsol10.dev.bloomberg.com:3000/vcpu/nydevsol10?content-type=application/json').
      then(function(response) {
        var kstat_data = response.data.body;
        var temp_array = [];
        var static_data = [];

        //while (kstat_data.length > 0) {
        //  var core = kstat_data.splice(0,8);
        //  temp_array.push(core);
        //}
        for (i = 0; i < kstat_data.length; i++) {
          var fdata = kstat_data[i];
          temp_array.push(fdata);
        }

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


          // watch for data changes and re-render
          scope.$watch('data', function(newVals, oldVals) {
            return scope.render(newVals);
          }, true);

          scope.render = function(data) {
            console.log("Entering render");

            // our custom d3 code

            // If we don't get any data, return out of the element
            if (!data) return;

            // set up variables
            // var width = d3.select(element[0]).node().offsetWidth;
            var table_bodies, table_rows, table_row_core_headers;

            // UPDATES
            tables = div.selectAll("table");

            table_rows = tables
              .data(data)
              .selectAll('tbody tr')
              .data(function(d,i) { return d.cores; });


            table_rows
              .selectAll('table tbody tr.data_row td')
              .data(function(d, i) { return d.cpus; })
              .style("color", function(d, i) { return colorScale(100 - d.stats.idl); })
              .html(
              function(d, i) {
                return '<div class="cpuname">' + d.cpu        + '</div>' +
                  '<div class="idle">'    + d.stats.idl  + '</div>'  +
                  '<div class="user">'    + d.stats.usr  + '</div>'  +
                  '<div class="sys">'     + d.stats.sys  + '</div>';
              }
            );

            // ==========================================================


            // TABLES ENTER SELECTION
            tables = div.selectAll("table")
              .data(data)
              .enter()
              .append("table")
              .append('thead')
              .append('tr')
              .append('th')
              .attr('colspan',9)
              .text(function(d) {return "Locality Group " + d.LG; });


            table_bodies = tables
              .append("tbody");

            //table_headers = tables
            //  .insert('thead','tbody')
            //  .append('tr')
            //  .append('th')
            //  .attr('colspan',9)
            //  .text(function(d) { return "Locality Group " + d.LG; });

            //table_headercols_row = table_bodies
            //  .append('tr')
            //  .append('th').attr('class','core_hdr');

            table_rows = table_bodies.selectAll('tr')
              .data(function(d,i) { return d.cores; })
              .enter()
              .append('tr')
              .classed('data_row',1);

            table_row_core_headers =
              table_rows
                .append('th').text(function(d) { return d.core; }).classed('core_ids',1);

            table_rows
              .selectAll('table tbody tr.data_row td')
              .data(function(d, i) { return d.cpus; })
              .enter()
              .append('td')
              .style("color", function(d, i) { return colorScale(100 - d.stats.idl); })
              .html(
              function(d, i) {
                return '<div class="cpuname">' + d.cpu        + '</div>' +
                  '<div class="idle">'    + d.stats.idl  + '</div>'  +
                  '<div class="user">'    + d.stats.usr  + '</div>'  +
                  '<div class="sys">'     + d.stats.sys  + '</div>';
              }
            );


            //var table_headercols_row = table_bodies
            //  .insert('tr','tr');
            //
            //table_headercols_row.append('th').attr('class','core_hdr');
            //table_headercols_row.append('th').attr('class','cpu_hdr');
            //table_headercols_row.append('th').attr('class','cpu_hdr');
            //table_headercols_row.append('th').attr('class','cpu_hdr');
            //table_headercols_row.append('th').attr('class','cpu_hdr');
            //table_headercols_row.append('th').attr('class','cpu_hdr');
            //table_headercols_row.append('th').attr('class','cpu_hdr');
            //table_headercols_row.append('th').attr('class','cpu_hdr');
            //table_headercols_row.append('th').attr('class','cpu_hdr');
            //
            //table_headercols_row.selectAll('th.core_hdr')
            //  .append('div')
            //  .attr('class','core_id')
            //  .text('CORE');
            //
            //table_headercols_row.selectAll('th.cpu_hdr')
            //  .append('div')
            //  .attr('class','cpuname')
            //  .text('CPU #');
            //
            //table_headercols_row.selectAll('th.cpu_hdr')
            //  .append('div')
            //  .attr('class','idle')
            //  .text('IDLE');
            //
            //table_headercols_row.selectAll('th.cpu_hdr')
            //  .append('div')
            //  .attr('class','user')
            //  .text('USER');
            //
            //table_headercols_row.selectAll('th.cpu_hdr')
            //  .append('div')
            //  .attr('class','sys')
            //  .text('SYS');

          }
        });
      }
    }
  }]
);
