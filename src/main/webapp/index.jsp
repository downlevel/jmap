<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>JMAP</title>
<link rel='stylesheet' id='style-css'  href='./css/geomap.css' type='text/css' media='all' />
<script type="text/javascript" src="http://maps.google.com/maps/api/js"></script>
<script src="./js/jquery-2.1.4.min.js"></script>


<script type="text/javascript">

//Definisco le variabili map e Geocoder

var geocoder;
var map;
var marker;
var markersArray = [];
var activeWindow;
var locIndex;
var locations;

function initialize() {

	var mapOptions = {
	center: new google.maps.LatLng(38.078918, 13.512365),
	zoom: 12,
	mapTypeId: google.maps.MapTypeId.ROADMAP
	};

var infoWindow = new google.maps.InfoWindow();
map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);

	locations = $.getJSON("/jmap/markers", function(data){
		for (var i=0, len=data.length; i < len; i++) {
				addMarker(data[i].lat, data[i].lng, data[i].name, data[i].address, data[i].category, i);
        }
	});

	printCategories();
}

function addMarker(lat,lng,name,address,category, idx){

	var latlng = new google.maps.LatLng(lat,lng);
	var infowindow = new google.maps.InfoWindow({
    content: "<div class=\"\mapFilterMap\"><div><b>"+name+"</b><br/>"+address+"</div></div>"
	});
	
	var iconBase = "./img/markers/";
	var marker = new google.maps.Marker({
    	position: latlng,
    	map: map,
    	category: category,
		title: name,
		icon: iconBase + category + '.png',
		infowindow: infowindow
    });
	marker.locid = idx+1;
	markersArray.push(marker);

	google.maps.event.addListener(marker, 'click', function() {

	if(activeWindow != null) activeWindow.close(); 

	infowindow.open(map,marker);

	activeWindow = infowindow; 

	});
	
	 var sideHtml = '<p class="loc" data-locid="'+marker.locid+'"><img src="./img/markers/'+category+'.png" class=\"markerLocation\"/><span class="locName"><b>'+marker.title+'</b></span><br/>';
	 sideHtml += '<span class="address">' + address + '</span></p>';
	 $("#locs").append(sideHtml); 
}

function printCategories(){
	
	var filterDiv = document.getElementById("map_filter");
	
	$.getJSON("/jmap/categories", function(data){
		for (var i=0; i< data.length; i++) {
			filterDiv.innerHTML += "<img src=\"./img/markers/"+data[i].name+".png\" class=\"markerFilter\" />"+data[i].name+"  <input type=\"checkbox\" name=\"category\" value=\""+data[i].name+"\"/>";
        }
	});
}

$(document).on("click",".loc",function() {
	var thisloc = $(this).data("locid");
	for(var i=0; i<markersArray.length; i++) {
		if(markersArray[i].locid == thisloc) {
			//get the latlong
			if(activeWindow instanceof google.maps.InfoWindow) activeWindow.close();
			map.panTo(markersArray[i].getPosition());
			markersArray[i].infowindow.open(map, markersArray[i]);
			activeWindow = markersArray[i].infowindow;
		}
	}
});


function doFilter() {
	if(!locIndex) {
		locIndex = {};
		//I reverse index markers to figure out the position of loc to marker index
		for(var x=0, len=markersArray.length; x<len; x++) {
			locIndex[markersArray[x].locid] = x;
		}
	}

	//what's checked?
	var checked = $("input[type=checkbox]:checked");
	var selTypes = [];
	for(var i=0, len=checked.length; i<len; i++) {
		selTypes.push($(checked[i]).val());
	}
	for(var i=0, len=markersArray.length; i<len; i++) {
		var sideDom = "p.loc[data-locid="+(i+1)+"]";

		//Only hide if length != 0
		if(checked.length !=0 && selTypes.indexOf(markersArray[i].category) < 0) {
			$(sideDom).hide();
			markersArray[locIndex[i+1]].setVisible(false);
		} else {
			$(sideDom).show();
			markersArray[locIndex[i+1]].setVisible(true);
		}
	}
}

$(document).on("click", "input[type=checkbox]", doFilter);


</script>


</head>
<body onload="initialize()">
<div id="topBar">
</div>
<div id="map_container">
<div id="map_filter">
</div>
<div id="locs"></div>
<div id="map_canvas" style="overflow: inherit !important; position: absolute; width:100%; height:100%;"></div>
</div>

</body>
</html>