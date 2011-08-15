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
  
  // var full_months = new Array("January","February","March","April","May","June","July","August","September","October","November","December");
  // var short_months = new Array("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
  
  // counts = {}
  
  var my_series = new Array();
  
  $.each(values, function(key, value) { 
     my_series.push({name: key, data: value.map(function(val){return parseInt(val,10)/1})})
  });

  // min = params['min']/100.0;
  // max = params['max']/100.0;
        
  new Highcharts.Chart({
    chart: {
      renderTo: element_id,
      defaultSeriesType: 'column'
    },
    credits: {
      enabled: false
    },
    title: {
      text: params['title']
    },
    
//    tooltip: {
//      formatter: function() {
//        return '<b>$ ' + this.y.toFixed(2) + '</b> ' + this.series.name + ' in <b>' + this.x + '</b>';
//        // return this.x + ': $ ' + this.y.toFixed(2);
//      }
//    },
    
    xAxis: {
      categories: categories
    },
    
    // xAxis: {
    //   categories: [
    //     'Jan', 
    //     'Feb', 
    //     'Mar', 
    //     'Apr', 
    //     'May', 
    //     'Jun', 
    //     'Jul', 
    //     'Aug', 
    //     'Sep', 
    //     'Oct', 
    //     'Nov', 
    //     'Dec'
    //   ]
    // },
    
    yAxis: {
      title: {
        text: params['ytitle'] || null
      },
//      labels: {
//        formatter: function(){
//          return ('$ ' + this.value);
//        }
//      },
//      min: min,
//      max: max
    },
    
    
    // yAxis: {
    //   maxPadding: 0.01,
    //   minPadding: 0.01,
    //   title:{
    //     text: 'Count'
    //   }
    // },
    series: my_series.reverse(),
    
    plotOptions: {
       column: {
          stacking: params['stacking']
       }
    }
    // plotOptions: {
    //    spline: {
    //       lineWidth: 3,
    //       marker: {
    //          enabled: false,
    //          states: {
    //             hover: {
    //                enabled: true,
    //                symbol: 'circle',
    //                radius: 5,
    //                lineWidth: 1
    //             }
    //          }   
    //       },
    //       pointInterval: 100,
    //       pointStart: 0
    //    }
    // }
  });
}