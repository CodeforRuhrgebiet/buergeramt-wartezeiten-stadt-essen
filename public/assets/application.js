var persoDataPoints = [];
var reiseDataPoints = [];
var anmeldungDataPoints = [];
var ummeldungDataPoints = [];

var drawPersoChart = function drawPersoChart() {
  $('#perso').highcharts({
    title: {
      text: 'Personalausweis beantragen',
      x: -20 //center
    },
    xAxis: {
      type: 'datetime'
    },
    yAxis: {
      title: {
        text: 'Wartezeit (Tage)'
      },
      plotLines: [{
        value: 0,
        width: 1,
        color: '#808080'
      }]
    },
    tooltip: {
      valueSuffix: ' Tage'
    },
    legend: {
      enabled: false
    },
    series: [{
      name: 'Wartezeit um einen Personalausweis zu beantragen',
      data: persoDataPoints
    }]
  });
};

var drawReiseChart = function drawReiseChart() {
  $('#reisepass').highcharts({
    title: {
      text: 'Reisepass beantragen',
      x: -20 //center
    },
    xAxis: {
      type: 'datetime'
    },
    yAxis: {
      title: {
        text: 'Wartezeit (Tage)'
      },
      plotLines: [{
        value: 0,
        width: 1,
        color: '#808080'
      }]
    },
    tooltip: {
      valueSuffix: ' Tage'
    },
    legend: {
      enabled: false
    },
    series: [{
      name: 'Wartezeit um einen Reisepass zu beantragen',
      data: reiseDataPoints
    }]
  });
};

var drawAnmeldungChart = function drawAnmeldungChart() {
  $('#anmeldung').highcharts({
    title: {
      text: 'Anmeldung',
      x: -20 //center
    },
    xAxis: {
      type: 'datetime'
    },
    yAxis: {
      title: {
        text: 'Wartezeit (Tage)'
      },
      plotLines: [{
        value: 0,
        width: 1,
        color: '#808080'
      }]
    },
    tooltip: {
      valueSuffix: ' Tage'
    },
    legend: {
      enabled: false
    },
    series: [{
      name: 'Wartezeit um sich bei der Stadt anzumelden',
      data: anmeldungDataPoints
    }]
  });
};

var drawUmmeldungChart = function drawUmmeldungChart() {
  $('#ummeldung').highcharts({
    title: {
      text: 'Ummeldung',
      x: -20 //center
    },
    xAxis: {
      type: 'datetime'
    },
    yAxis: {
      title: {
        text: 'Wartezeit (Tage)'
      },
      plotLines: [{
        value: 0,
        width: 1,
        color: '#808080'
      }]
    },
    tooltip: {
      valueSuffix: ' Tage'
    },
    legend: {
      enabled: false
    },
    series: [{
      name: 'Wartezeit um sich bei der Stadt umzumelden',
      data: ummeldungDataPoints
    }]
  });
};

var setData = function setData() {
  persoRef = firebase.database().ref("cases/perso-beantragen");
  var persoQuery = persoRef.orderByChild("angefragt_timestamp").limitToLast(100);
  persoQuery.on("value", function(snapshot) {
    snapshot.forEach(function(data) {
      // console.log(data.val());
      var date = new Date(data.val().angefragt_timestamp * 1000);
      var xValue = Date.UTC(date.getFullYear(), date.getMonth(), date.getDate());
      var yValue = data.val().wartezeit;
      var dataPoint = [xValue, yValue];
      persoDataPoints.push(dataPoint);
      drawPersoChart();
    });
  });

  reiseRef = firebase.database().ref("cases/reisepass-beantragen");
  var reiseQuery = reiseRef.orderByChild("angefragt_timestamp").limitToLast(100);
  reiseQuery.on("value", function(snapshot) {
    snapshot.forEach(function(data) {
      // console.log(data.val());
      var date = new Date(data.val().angefragt_timestamp * 1000);
      var xValue = Date.UTC(date.getFullYear(), date.getMonth(), date.getDate());
      var yValue = data.val().wartezeit;
      var dataPoint = [xValue, yValue];
      reiseDataPoints.push(dataPoint);
      drawReiseChart();
    });
  });

  anmeldungRef = firebase.database().ref("cases/anmeldung");
  var anmeldungQuery = anmeldungRef.orderByChild("angefragt_timestamp").limitToLast(100);
  anmeldungQuery.on("value", function(snapshot) {
    snapshot.forEach(function(data) {
      var date = new Date(data.val().angefragt_timestamp * 1000);
      var xValue = Date.UTC(date.getFullYear(), date.getMonth(), date.getDate());
      var yValue = data.val().wartezeit;
      var dataPoint = [xValue, yValue];
      anmeldungDataPoints.push(dataPoint);
      drawAnmeldungChart();
    });
  });

  ummeldungRef = firebase.database().ref("cases/ummeldung");
  var ummeldungQuery = ummeldungRef.orderByChild("angefragt_timestamp").limitToLast(100);
  ummeldungQuery.on("value", function(snapshot) {
    snapshot.forEach(function(data) {
      var date = new Date(data.val().angefragt_timestamp * 1000);
      var xValue = Date.UTC(date.getFullYear(), date.getMonth(), date.getDate());
      var yValue = data.val().wartezeit;
      var dataPoint = [xValue, yValue];
      ummeldungDataPoints.push(dataPoint);
      drawUmmeldungChart();
    });
  });
};

window.onload = function () {
  setData();
};
