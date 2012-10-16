/*!
* global.js by @remomueller
* Copyright 2012 Remo Mueller
* http://creativecommons.org/licenses/by-nc-sa/3.0/legalcode
*/

(function() {
  jQuery(function() {
    $("tr[data-link]").on('click', function() {
      return window.location = $(this).data("link");
    });
  });
}).call(this);
