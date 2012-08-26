function redirectToSubChannel(event) {
	event = event || window.event;

	var video = document.getElementById("videoarea");

	var xDiv = event.clientX > (video.clientWidth / 2) ? 1 : 0;
	var yDiv = event.clientY > (video.clientHeight / 2) ? 1 : 0;

/*
 *	Use the following division of the video area:
 *
 *	---------------------
 *	|         |         |
 *	|    1    |    2    |
 *	|         |         |
 *	|-------------------|
 *	|         |         |
 *	|    3    |    4    |
 *	|         |         |
 *	---------------------
 *
 *	And calculate the proper tile number based on the
 *	calculated relative coordinates.
 */

	var chNum = 2 * yDiv + xDiv + 1;
	var attribName = "subchannel-" + chNum;
	var chanLink = video.dataset[attribName];

	window.location = chanLink;
}

function changeMousePointer(event) {
	var video = document.getElementById("videoarea");

	video.style.cursor = "crosshair";
}

function restyleClasses() {
	var noJs = document.getElementsByClassName("noJs");

	for (var idx = 0; idx < noJs.length; idx++)
		noJs[idx].style.display = "none";

	var hasJs = document.getElementsByClassName("hasJs");

	for (var idx = 0; idx < hasJs.length; idx++) {
		hasJs[idx].style.display = "block";
	}
}

window.onload = restyleClasses;
