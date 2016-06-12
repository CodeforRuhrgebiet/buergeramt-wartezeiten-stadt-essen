var persoDataPoints = [];

var drawChart = function drawChart() {
  $('#chart1').highcharts({
    title: {
      text: 'Personalausweis beantragen',
      x: -20 //center
    },
    subtitle: {
      text: 'Quelle: meintermin.essen.de',
      x: -20
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

window.onload = function () {
  persoRef = firebase.database().ref("cases/perso");
  var persoQuery = persoRef.orderByChild("angefragt_timestamp").limitToLast(100);
  persoQuery.on("value", function(snapshot) {
    snapshot.forEach(function(data) {
      var date = new Date(data.val().angefragt_timestamp * 1000);
      var xValue = Date.UTC(date.getFullYear(), date.getMonth(), date.getDate());
      var yValue = data.val().wartezeit;
      var dataPoint = [xValue, yValue];
      persoDataPoints.push(dataPoint);
    });

    drawChart();
  });
};
