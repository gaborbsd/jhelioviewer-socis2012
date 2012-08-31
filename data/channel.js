/*
 * Handles onclick() on the video area and reads the
 * subchannel references in the data-subchannel# attribute,
 * where # is the subchannel number. Determines which subchannel
 * the click belongs to and redirects the user to the
 * corresponding subchannel.
 */
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

/*
 * Change to mouse pointer to a cross when over the
 * video area to indicate that the user can click there.
 */
function changeMousePointer(event) {
	var video = document.getElementById("videoarea");

	video.style.cursor = "crosshair";
}

/*
 * Handles onload() for the window. Hides parts that
 * are only meant for people, who do not have JavaScript
 * enabled and shows parts that are only applicable if
 * JavaScript is enabled.
 */
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
