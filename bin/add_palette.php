<?php

/*
 * Applies color palette to images.
 *
 * Usage: php add_palette.sh <pic.png> <palette.png>
 */

$gd = imagecreatefrompng($argv[1]);
$ctable = imagecreatefrompng($argv[2]);

// Read palette and apply color for each palette index
for ($i = 0; $i <= 255; $i++) {
	$rgb = imagecolorat($ctable, 0, $i);
	$r = ($rgb >> 16) & 0xFF;
	$g = ($rgb >> 8) & 0xFF;
	$b = $rgb & 0xFF;
	imagecolorset($gd, $i, $r, $g, $b);
}

// Save and clean up
imagepng($gd, $input);
imagedestroy($gd);
imagedestroy($ctable);
?>
