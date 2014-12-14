jQuery(document).ready(function ($) {

jQuery(document).ready(function(){
var params = {
		changedEl: "select",
		visRows: 5,
		scrollArrows: true
	}
	cuSel(params);
});


$('.panel-heading a').click(function() {
    $('.panel-heading').removeClass('actives');
    //$('this').parent().toggleClass('actives');
    $(this).parents('.panel-heading').toggleClass('actives');
});


$('#result .nav-tabs li a').click(function() {
	$(this).after('<span></span>');
});



});