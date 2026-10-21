<?php
$IMG_FOLDER = "Source/images/ega/level/";

$contents = file_get_contents("Source/LevelMaps.bm");
$levels = array();
$lvl = array();
foreach (explode("\n", $contents) as $line)
{
	if (substr($line, 0, 6) !== "Data \"")
	{
		continue;
	}
	if (strtolower(substr($line, 6, 1)) === "x")
	{
		$levels[] = $lvl;
		$lvl = array();
		continue;
	}
	$idx = 6;
	$lev_line = array();
	while ($idx < strlen($line) - 1)
	{
		$chr = substr($line, $idx, 1);
		$lev_line[] = $chr;
		$idx++;
	}
	$lvl[] = $lev_line;
}

$sprites = array(
	"@" => array("data" => imagecreatefrompng($IMG_FOLDER . "BlockBlue.png"), "offset" => array(0 => 0, 1 => 0)),
	"#" => array("data" => imagecreatefrompng($IMG_FOLDER . "BlockWhite.png"), "offset" => array(0 => 0, 1 => 0)),
	"c" => array("data" => imagecreatefrompng($IMG_FOLDER . "Cookie.png"), "offset" => array(0 => 0, 1 => 0)),
	"!" => array("data" => imagecreatefrompng($IMG_FOLDER . "Pole.png"), "offset" => array(0 => 0, 1 => 0)),
	"c" => array("data" => imagecreatefrompng($IMG_FOLDER . "Cookie.png"), "offset" => array(0 => 0, 1 => 0)),
	"m" => array("data" => imagecreatefrompng($IMG_FOLDER . "Mittens.png"), "offset" => array(0 => 0, 1 => 0)),
	"t" => array("data" => imagecreatefrompng($IMG_FOLDER . "Tuque.png"), "offset" => array(0 => 0, 1 => 0)),
	"~" => array("data" => imagecreatefrompng($IMG_FOLDER . "Water.png"), "offset" => array(0 => 0, 1 => 0)),
	"S" => array("data" => imagecreatefrompng($IMG_FOLDER . "Snow_C.png"), "offset" => array(0 => 0, 1 => 0)),
	"*" => array("data" => imagecreatefrompng($IMG_FOLDER . "Water.png"), "offset" => array(0 => 0, 1 => 0)),
	"f" => array("data" => imagecreatefrompng($IMG_FOLDER . "Coffee.png"), "offset" => array(0 => 0, 1 => 0))
);

foreach ($sprites as $k => $i)
{
	$grey = imagecolorexact($i["data"], 0x34, 0x34, 0x34);
    if ($grey >= 0)
    {
        imagecolortransparent($i["data"], $grey);
    }
    imagealphablending($i["data"], false);
    imagesavealpha($i["data"], true);
}

for ($l = 0; $l < count($levels); $l++)
{
	$lvl = $levels[$l];
	$h = count($lvl);
	$w = count($lvl[0]);
	$img = imagecreatetruecolor($w * 11, $h * 11);
	for ($row = 0; $row < $h; $row++)
	{
		for ($col = 0; $col < $w; $col++)
		{
			$chr = $lvl[$row][$col];
			if ($chr === " ")
				continue;
			echo $chr;
			imagecopymerge($img, $sprites[$chr]["data"], $col * 11 + $sprites[$chr]["offset"][0], $row * 11 + $sprites[$chr]["offset"][1], 0, 0, 11, 11, 100);
		}
	}
	imagepng(imagescale($img, $w * 11 * 4, -1, IMG_NEAREST_NEIGHBOUR), sprintf("%02d.png", $l));
}
//print_r($levels);
?>