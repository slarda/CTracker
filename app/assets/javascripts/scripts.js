$(function() {
	$('.navbar-toggle').on( 'click', function( event ) {
		$(this).toggleClass( 'collapsed' );
		$('body').toggleClass( 'nav-open' );
	});

	// force touching the overlay to fire a click event on .navbar-toggle
	$('.nav-content-overlay').on( 'click', function( event ) {
		$('.navbar-toggle').trigger( 'click' );
	});
	/* setTimeout(function() {
	    $('.chart-1').easyPieChart({
	    	barColor: '#ff206f',
	    	trackColor: false,
	    	scaleColor: false,
	    	lineCap: 'round',
	    	lineWidth: 8,
	    	size: 120,
	    	animate: 1200
	    });
	    $('.chart-2').easyPieChart({
	    	barColor: '#03a4cc',
	    	trackColor: false,
	    	scaleColor: false,
	    	lineCap: 'round',
	    	lineWidth: 8,
	    	size: 120,
	    	animate: 1200
	    });
	    $('.chart-3').easyPieChart({
	    	barColor: '#a1d417',
	    	trackColor: false,
	    	scaleColor: false,
	    	lineCap: 'round',
	    	lineWidth: 8,
	    	size: 120,
	    	animate: 1200
	    });
	 }, 1000);*/
	$('[class*="chart-"').on( 'click', function( event ) {
		$(this).data('easyPieChart').update(-60);
	});
});



$(function() {

    // initialist tooltips
    $('[data-toggle="tooltip"]').tooltip();

    //$('#sampleMap #map-canvas').on('shown.bs.modal', function () {
    //    console.log('stuff');
    //    google.maps.event.trigger(map, "resize");
    //});

    //$('.share-action a').on( 'click', function( event ) {
    //    event.preventDefault();
    //    $( this ).closest( '.share-element' ).toggleClass( 'is-active' );
    //});

    //$('.equal-heights .equal-height').equalHeightColumns({
    //    minWidth: 700,
    //    maxWidth: 5000
    //});
    //$( window ).resize(function() {
    //    $('.equal-heights .equal-height').equalHeightColumns({
    //        minWidth: 700,
    //        maxWidth: 5000
    //    });
    //});
});


//function initialize() {
//    var mapCanvas = document.getElementById('map-canvas');
//    var mapOptions = {
//        center: new google.maps.LatLng(-37.905506, 145.100046),
//        zoom: 8,
//        mapTypeId: google.maps.MapTypeId.ROADMAP
//    }
//    var map = new google.maps.Map(mapCanvas, mapOptions)
//}
//google.maps.event.addDomListener(window, 'load', initialize);

    /* equalHeightColumns.js 1.2, https://github.com/PaulSpr/jQuery-Equal-Height-Columns */
//(function(e){e.fn.equalHeightColumns=function(t){defaults={minWidth:-1,maxWidth:99999,setHeightOn:"min-height",defaultVal:0,equalizeRows:false,checkHeight:"height"};var n=e(this);t=e.extend({},defaults,t);var r=function(){var r=e(window).width();var i=Array();if(t.minWidth<r&&t.maxWidth>r){var s=0;var o=0;var u=0;n.css(t.setHeightOn,t.defaultVal);n.each(function(){if(t.equalizeRows){var n=e(this).position().top;if(n!=u){if(i.length>0){e(i).css(t.setHeightOn,o);o=0;i=[]}u=e(this).position().top}i.push(this)}s=e(this)[t.checkHeight]();if(s>o){o=s}});if(!t.equalizeRows){n.css(t.setHeightOn,o)}else{e(i).css(t.setHeightOn,o)}}else{n.css(t.setHeightOn,t.defaultVal)}};r();e(window).resize(r);n.find("img").load(r);if(typeof t.afterLoading!=="undefined"){n.find(t.afterLoading).load(r)}if(typeof t.afterTimeout!=="undefined"){setTimeout(function(){r();if(typeof t.afterLoading!=="undefined"){n.find(t.afterLoading).load(r)}},t.afterTimeout)}}})(jQuery)