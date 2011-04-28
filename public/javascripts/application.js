// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function createSpinner() {
  return new Element('img', { src: root_url + 'images/ajax-loader.gif', 'class': 'spinner', 'height': '11', 'width': '11' });
}

$(function(){
  $(".datepicker").datepicker({ showOtherMonths: true, selectOtherMonths: true, changeMonth: true, changeYear: true });  
  $("#ui-datepicker-div").hide();
  
  $(".pagination a, .page a, .next a, .prev a").live("click", function() {
    // $(".pagination").html(createSpinner()); //.html("Page is loading...");
    $.get(this.href, null, null, "script")
    return false;
  });
  
  $("#comments_search input").change(function() {
    $.get($("#comments_search").attr("action"), $("#comments_search").serialize(), null, "script");
    return false;
  });
  
  $(".field_with_errors input, .field_with_errors_cleared input, .field_with_errors textarea, .field_with_errors_cleared textarea").change(function() {
    var el = $(this);
    if(el.val() != '' && el.val() != null){
      $(el).parent().removeClass('field_with_errors');
      $(el).parent().addClass('field_with_errors_cleared');
    }else{
      $(el).parent().removeClass('field_with_errors_cleared');
      $(el).parent().addClass('field_with_errors');
    }
  });
  
  // $("#stickies_search input, #stickies_search select").change(function() {
  $("#stickies_search select").change(function() {
    $.get($("#stickies_search").attr("action"), $("#stickies_search").serialize(), null, "script");
    return false;
  });
  
  $(".per_page a").live("click", function() {
    object_class = $(this).data('object')
    $.get($("#"+object_class+"_search").attr("action"), $("#"+object_class+"_search").serialize() + "&"+object_class+"_per_page="+ $(this).data('count'), null, "script");
    return false;
  });
  
  $("#sticky_project_id").change(function(){
    $.post(root_url + 'projects/selection', $("#sticky_project_id").serialize(), null, "script")
    return false;
  });
  
});

/* Mouse Out Functions to Show and Hide Divs */

function isTrueMouseOut(e, handler) {
	if (e.type != 'mouseout') return false;
	var relTarget;
  if (e.relatedTarget) {
    relTarget = e.relatedTarget;
  } else if (e.type == 'mouseout') {
    relTarget = e.toElement;
  } else {
    relTarget = e.fromElement;
  }
  while (relTarget && relTarget != handler) {
    relTarget = relTarget.parentNode;
  }
	return (relTarget != handler);
}

function hideOnMouseOut(elements){
  $.each(elements, function(index, value){
    var element = $(value);
    element.mouseout(function(e, handler) {
      if (isTrueMouseOut(e||window.event, this)) element.hide();
    });
  });
}

function showMessage(elements){
  $.each(elements, function(index, value){
    var element = $(value);
    element.fadeIn(2000);
  })
}

function toggleSticky(element){
  $(element).toggle();
  $(element+'_description').toggleClass('collapsed');
}

function increaseSelectedIndex(element){
  var num_options = $(element + ' option').size()
  var element = $(element);
  var next_index = 0;
  if(element.attr('selectedIndex') <= 0){
    return false;
  }else{
    next_index = element.attr('selectedIndex') - 1;
  }
  element.attr('selectedIndex', next_index);
  element.change();
}

function decreaseSelectedIndex(element){
  var num_options = $(element + ' option').size()
  var element = $(element);
  var next_index = 0;
  if(element.attr('selectedIndex') < num_options - 1){
    next_index = element.attr('selectedIndex') + 1;
  }else{
    return false;
  }
  element.attr('selectedIndex', next_index);
  element.change();
}

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
    	'#B5CA92'
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
        text: null
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
    },
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