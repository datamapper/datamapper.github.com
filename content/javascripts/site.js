$(document).ready(function() {
  $('#navigation a')
    .css( {backgroundPosition: "-250px 0"} )
    .mouseover(function(){
      $(this).stop().animate(
      {backgroundPosition:"(0 0)"}, 
      {duration:600})
    })
    .mouseout(function(){
      $(this).stop().animate(
      {backgroundPosition:"(-250px 0)"}, 
      {duration:300})
    });

  var current = $("#navigation a.current");
  $("#navigation")
    .mouseover(function() { current.removeClass("current"); })
    .mouseout(function() { current.addClass("current"); });
});
