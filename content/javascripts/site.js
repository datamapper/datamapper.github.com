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
    
  if ($("#home").get(0)) {
    var blurb = $("#blurb");
    var info = $("#more-info");
    info.css({opacity: 0});
    blurb.css({opacity: 0, backgroundPosition: "931px 0"});
    
    $(window).load(function() {
      blurb.animate({opacity: 1}, 2000, function() {
        blurb.animate({backgroundPosition: "(480px 0)"}, 500);
        info.animate({opacity: 1}, 1000);
      });
      
    });
  }
});
