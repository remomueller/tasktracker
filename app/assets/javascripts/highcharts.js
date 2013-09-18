function drawHighChartHistogramChart(element_id, values, params, categories){

  Highcharts.setOptions({
    colors: [
      '#AA4643',
    	'#89A54E',
    	'#4572A7',
    	'#80699B',
    	'#3D96AE',
    	'#DB843D',
    	'#92A8CD',
    	'#A47D7C',
    	'#B5CA92',
    	'#058DC7', '#50B432', '#ED561B', '#DDDF00', '#24CBE5', '#64E572', '#FF9655', '#FFF263', '#6AF9C4'
    ]
  });

  var my_series = new Array();

  $.each(values, function(key, value) {
     my_series.push({name: key, data: value.map(function(val){return parseInt(val,10)/1})})
  });

  new Highcharts.Chart({
    chart: {
      renderTo: element_id,
      defaultSeriesType: params['chart_type']
    },
    credits: {
      enabled: false
    },
    title: {
      text: params['title']
    },

    xAxis: {
      categories: categories
    },

    yAxis: {
      title: {
        text: params['ytitle'] || null
      },
    },


    series: my_series.reverse(),

    plotOptions: {
       column: {
          stacking: params['stacking']
       }
    }
  });
}
