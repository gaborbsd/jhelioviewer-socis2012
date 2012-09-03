<?php

function setColorPalette($input, $table) {
	$gd = imagecreatefrompng($input);
        $ctable = imagecreatefrompng($table);

        // Apply color table
        for ($i = 0; $i <= 255; $i++) {
            $rgb = imagecolorat($ctable, 0, $i);
            $r = ($rgb >> 16) & 0xFF;
            $g = ($rgb >> 8) & 0xFF;
            $b = $rgb & 0xFF;
            imagecolorset($gd, $i, $r, $g, $b);
        }

        imagepng($gd, $input);

        imagedestroy($gd);
        imagedestroy($ctable);
}

setColorPalette($argv[1], $argv[2]);
?>
