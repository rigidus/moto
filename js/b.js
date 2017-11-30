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

function getChildIds(selector) {
    return $(selector).children().map(function (i, elt) {
        return [$(elt).attr("id")];
    }).get();
};
function save() {
    $.post("#", { "act" : "SAVE",
                  "not" : getChildIds("#unsort").join(),
                  "yep" : getChildIds("#uninteresting").join()
                }, function (data, status) {
                    return status != "success" ? alert("err-ajax-fail: " + status) : eval(data);
                });
    return false;
};
