/*
 * HTML5 Sortable jQuery Plugin
 * http://farhadi.ir/projects/html5sortable
 *
 * Copyright 2012, Ali Farhadi
 * Released under the MIT license.
 */
(function($) {
  var dragging, placeholders = $();
  $.fn.sortable = function(options) {
    var method = String(options);
    options = $.extend({
      connectWith: false
    }, options);
    return this.each(function() {
      if (/^enable|disable|destroy$/.test(method)) {
        var items = $(this).children($(this).data('items')).attr('draggable', method == 'enable');
        if (method == 'destroy') {
          items.add(this).removeData('connectWith items')
            .off('dragstart.h5s dragend.h5s selectstart.h5s dragover.h5s dragenter.h5s drop.h5s');
        }
        return;
      }
      var isHandle, index, items = $(this).children(options.items);
      var placeholder = $('<' + (/^ul|ol$/i.test(this.tagName) ? 'li' : 'div') + ' class="sortable-placeholder">');
      items.find(options.handle).mousedown(function() {
        isHandle = true;
      }).mouseup(function() {
        isHandle = false;
      });
      $(this).data('items', options.items)
      placeholders = placeholders.add(placeholder);
      if (options.connectWith) {
        $(options.connectWith).add(this).data('connectWith', options.connectWith);
      }
      items.attr('draggable', 'true').on('dragstart.h5s', function(e) {
        if (options.handle && !isHandle) {
          return false;
        }
        isHandle = false;
        var dt = e.originalEvent.dataTransfer;
        dt.effectAllowed = 'move';
        dt.setData('Text', 'dummy');
        index = (dragging = $(this)).addClass('sortable-dragging').index();
      }).on('dragend.h5s', function() {
        if (!dragging) {
          return;
        }
        dragging.removeClass('sortable-dragging').show();
        placeholders.detach();
        if (index != dragging.index()) {
          dragging.parent().trigger('sortupdate', {item: dragging});
        }
        dragging = null;
      }).not('a[href], img').on('selectstart.h5s', function() {
        this.dragDrop && this.dragDrop();
        return false;
      }).end().add([this, placeholder]).on('dragover.h5s dragenter.h5s drop.h5s', function(e) {
        if (!items.is(dragging) && options.connectWith !== $(dragging).parent().data('connectWith')) {
          return true;
        }
        if (e.type == 'drop') {
          e.stopPropagation();
          placeholders.filter(':visible').after(dragging);
          dragging.trigger('dragend.h5s');
          return false;
        }
        e.preventDefault();
        e.originalEvent.dataTransfer.dropEffect = 'move';
        if (items.is(this)) {
          if (options.forcePlaceholderSize) {
            placeholder.height(dragging.outerHeight());
          }
          dragging.hide();
          $(this)[placeholder.index() < $(this).index() ? 'after' : 'before'](placeholder);
          placeholders.not(placeholder).detach();
        } else if (!placeholders.is(this) && !$(this).children(options.items).length) {
          placeholders.detach();
          $(this).append(placeholder);
        }
        return false;
      });
    });
  };
})(jQuery);


function getChildIds (selector) {
  return $(selector).children().map(function (i, elt) {
    return [$(elt).attr("id")];
  }).get();
}

function save_state () {
  $.post("/hh", { "act" : "save",
                  "unsort" : getChildIds('#unsort-container').join(),
                  "interested" : getChildIds('#interested').join(),
                  "not_interested" : getChildIds('#not_interested').join()
                }, function (data) {},
         "json");
  return false;
}

$(function() {
  $('.connected').sortable({
    connectWith: '.connected',
    handle: '.handle'
  });
});



function asmVac(data) {
  var tmp = "";
  if ("false" != data.salaryText) {
    tmp = data.salaryText;
  }
  return "<li id=\'" + data.id + "\'>"
    + "<span class=\"handle\">&nbsp;&nbsp;&nbsp;&nbsp;</span>"
    + "&nbsp;&nbsp;"
    + data.name
    + "&nbsp;&nbsp;"
    + "<span style='color:red'>"
    + tmp
    + "</span>"
    + "</li>";
}

function contains(str, ptrn) {
  if (-1 != str.indexOf(ptrn)) {
    return true;
  } else {
    return false;
  }
}

function loadElts(param) {

  $('.connected').sortable('destroy');

  alert(8);

  $.post("/collection", { "act" : param }, function (data) {
    $("#unsort-container").html("");
    $("#interesting-container").html("");
    $("#not-interesting-container").html("");
    $.each(data, function (i, data) {
      if ("false" == data.salaryText) {
        $("#unsort-container").append(asmVac(data));
      } else {
        if (contains(data.name, 'Java') ||
            contains(data.name, 'PHP')) {
          $("#interesting-container").append(asmVac(data));
        } else {
          if (contains(data.name, 'Android') ||
              contains(data.name,'1C')) {
            $("#not-interesting-container").append(asmVac(data));

          }
        }
      }
    });
  }, "json");

  alert(6);

  $('.connected').sortable({ connectWith: '.connected', handle: '.handle'});

  return false;

};

function vacHook(vac) {
  return null;
};
// loadElts("stub");


function ShowHide(id)
{
	if (document.getElementById(id).style.display == 'none') {
		document.getElementById(id).style.display = 'block';
	} else {
		document.getElementById(id).style.display = 'none';
	}
	return false;
}
