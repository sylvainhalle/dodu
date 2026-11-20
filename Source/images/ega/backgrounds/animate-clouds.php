<?php

$infile = "Clouds_1.png";
for ($i = 0; $i < 160; $i++)
{
	exec(sprintf("magick %s -crop 160x128+%d+0 /tmp/cropped_%03d.png", $infile, $i, $i));
}
exec("convert +append /tmp/cropped*.png Clouds_animated.png");

?>