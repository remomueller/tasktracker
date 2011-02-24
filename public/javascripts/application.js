// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


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
// alert('relTarget type:' + relTarget.tagName + " - " + relTarget.innerHTML);
  while (relTarget && relTarget != handler) {
    relTarget = relTarget.parentNode;
  }
	return (relTarget != handler);
}

function hideOnMouseOut(elements){
  elements.each(function(element){
    var element = $(element);
    element.onmouseout = function(e, handler) {
      if (isTrueMouseOut(e||window.event, this)) this.hide();
    }
  });
}