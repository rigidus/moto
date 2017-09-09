function tggl (on, off, ctrl, me) {
  if ($(ctrl).is(":hidden")) {
    setTimeout(function(){
      $(me).text(off);
      $(me).removeClass("btn-info");
      $(me).addClass("btn-primary");
      $(ctrl).show();
    }, 200);
  }
  if ($(ctrl).is(":visible")) {
    setTimeout(function(){
      $(me).text(on);
      $(me).removeClass("btn-primary");
      $(me).addClass("btn-info");
      $(ctrl).hide();
    }, 200);
  }
  return false;
}
