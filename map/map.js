var map = null;
var markers = [];
var activeMarker = -1;

function initialize() {
	var mapOptions = {
		zoom: 10,
		disableDefaultUI: !0,
		panControl: !1,
		zoomControl: !0,
		zoomControlOptions: {
			style: google.maps.ZoomControlStyle.SMALL,
		},
		mapTypeControl: !0,
		mapTypeControlOptions: {
			style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
		},
		scaleControl: !0,
		overviewMapControl: !0,
		streetViewControl: !0,
            	center: new google.maps.LatLng(59.956385,30.338516)
	};
	map = new google.maps.Map(document.getElementById('map'), mapOptions);

	var nodes = document.querySelectorAll('#data a');
	for (var i = 0, j = nodes.length; i < j; i++) {
		var rel = nodes[i].getAttribute('rel');
		var coord = rel.split(',');
		var price = nodes[i].querySelector('.object-sprice b').innerHTML.replace('Цена от:', 'От');
		var marker = new RichMarker({
			position: new google.maps.LatLng(coord[0].trim(), coord[1].trim()),
			map: map,
			anchor: RichMarkerPosition.TOP_LEFT,
			content: '<div class="marker">' + price + '</div>'
		});
		marker.setZIndex(1);
		nodes[i].setAttribute('data-marker', markers.length);
		markers.push(marker);
	}

	google.maps.event.addDomListener(document.querySelector('#data'), 'mouseover', function(event) {
		var node = event.target;
		while (node && node.tagName != 'A')
			node = node.parentElement;
		if (!node)
			return;
		var idx = parseInt(node.getAttribute('data-marker'));
		if (idx == activeMarker)
			return;
		if (activeMarker >= 0) {
			markers[activeMarker].setContent(markers[activeMarker].getContent().replace('marker marker-active', 'marker'));
			markers[activeMarker].setZIndex(1);
		}
		markers[idx].setContent(markers[idx].getContent().replace('marker', 'marker marker-active'));
		markers[idx].setZIndex(10000);
		activeMarker = idx;
		var rel = node.getAttribute('rel');
		var coord = rel.split(',');
		map.panTo(new google.maps.LatLng(coord[0].trim(), coord[1].trim()));
		//console.log(markers[2].getContent());
//		console.log(node, markers[idx]);
	});

}

//google.maps.visualRefresh = true;
google.maps.event.addDomListener(window, 'load', initialize);
