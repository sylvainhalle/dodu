<?php
$LVL_FOLDER = "Source/images/ega/level/";
$BG_FOLDER = "Source/images/ega/backgrounds/";

$contents = file_get_contents("Source/LevelMaps.bm");
$levels = array();
$lvl = array("bg" => 0, "map" => array());
foreach (explode("\n", $contents) as $line)
{
	if (substr($line, 0, 6) !== "Data \"")
	{
		if (preg_match("/^Data (-?[0-9]+), (-?[0-9]+), (-?[0-9]+), (-?[0-9]+)/", $line, $matches))
		{
			$lvl["bg"] = $matches[1];
		}
		continue;
	}
	if (strtolower(substr($line, 6, 1)) === "x")
	{
		$levels[] = $lvl;
		$lvl = array("bg" => 0, "map" => array());
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
	$lvl["map"][] = $lev_line;
}


$backgrounds = array(
	array("data" => imagecreatefromgif($BG_FOLDER . "Blue_1.gif"), "offset" => array(0 => 0, 1 => 0), "size" => array(20, 20)),
	array("data" => imagecreatefromgif($BG_FOLDER . "Blue_2.gif"), "offset" => array(0 => 0, 1 => 0), "size" => array(20, 20)),
	array("data" => imagecreatefromgif($BG_FOLDER . "Cards.gif"), "offset" => array(0 => 0, 1 => 0), "size" => array(20, 20)),
	array("data" => imagecreatefromgif($BG_FOLDER . "Cyan_1.gif"), "offset" => array(0 => 0, 1 => 0), "size" => array(20, 20)),
	array("data" => imagecreatefromgif($BG_FOLDER . "Cyan_2.gif"), "offset" => array(0 => 0, 1 => 0), "size" => array(20, 20)),
	array("data" => imagecreatefrompng($BG_FOLDER . "Snow_1.png"), "offset" => array(0 => 0, 1 => 0), "size" => array(20, 20)),
	array("data" => imagecreatefrompng($BG_FOLDER . "Pizza_1.png"), "offset" => array(0 => 0, 1 => 0), "size" => array(40, 40)),
	array("data" => imagecreatefrompng($BG_FOLDER . "Pizza_2.png"), "offset" => array(0 => 0, 1 => 0), "size" => array(40, 40)),
	array("data" => imagecreatefrompng($BG_FOLDER . "Digits.png"), "offset" => array(0 => 0, 1 => 0), "size" => array(20, 20)),
	array("data" => imagecreatefrompng($BG_FOLDER . "Snow_2b.png"), "offset" => array(0 => 0, 1 => 0), "size" => array(20, 20)),
);

$sprites = array(
	"@" => array("data" => imagecreatefrompng($LVL_FOLDER . "BlockBlue.png"), "offset" => array(0 => 0, 1 => 0), "size" => array(11, 11)),
	"#" => array("data" => imagecreatefrompng($LVL_FOLDER . "BlockWhite.png"), "offset" => array(0 => 0, 1 => 0), "size" => array(11, 11)),
	"c" => array("data" => imagecreatefrompng($LVL_FOLDER . "Cookie.png"), "offset" => array(0 => 0, 1 => 0), "size" => array(11, 11)),
	"!" => array("data" => imagecreatefrompng($LVL_FOLDER . "Pole.png"), "offset" => array(0 => 1, 1 => -9), "size" => array(10, 20)),
	"c" => array("data" => imagecreatefrompng($LVL_FOLDER . "Cookie.png"), "offset" => array(0 => 2, 1 => 2), "size" => array(7, 7)),
	"m" => array("data" => imagecreatefrompng($LVL_FOLDER . "Mittens.png"), "offset" => array(0 => -2, 1 => 2), "size" => array(15, 7)),
	"t" => array("data" => imagecreatefrompng($LVL_FOLDER . "Tuque.png"), "offset" => array(0 => 1, 1 => -3), "size" => array(10, 13)),
	"~" => array("data" => imagecreatefrompng($LVL_FOLDER . "Water.png"), "offset" => array(0 => 0, 1 => 0), "size" => array(11, 11)),
	"C" => array("data" => imagecreatefrompng($LVL_FOLDER . "Snow_C.png"), "offset" => array(0 => 0, 1 => -14), "size" => array(11, 25)),
	"L" => array("data" => imagecreatefrompng($LVL_FOLDER . "Snow_L.png"), "offset" => array(0 => 0, 1 => -14), "size" => array(11, 25)),
	"R" => array("data" => imagecreatefrompng($LVL_FOLDER . "Snow_R.png"), "offset" => array(0 => 0, 1 => -14), "size" => array(11, 25)),
	"M" => array("data" => imagecreatefrompng($LVL_FOLDER . "Snow_M.png"), "offset" => array(0 => 0, 1 => 0), "size" => array(11, 11)),
	"*" => array("data" => imagecreatefrompng($LVL_FOLDER . "Mark.png"), "offset" => array(0 => 0, 1 => 0), "size" => array(11, 11)),
	"f" => array("data" => imagecreatefrompng($LVL_FOLDER . "Coffee.png"), "offset" => array(0 => 1, 1 => 1), "size" => array(9, 9))
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
	$h = count($lvl["map"]);
	$w = count($lvl["map"][0]);
	echo $lvl["bg"];
	$img = imagecreatetruecolor($w * 11, $h * 11);
	for ($x = 0; $x < $w * 11 + $backgrounds[$lvl["bg"]]["size"][0]; $x += $backgrounds[$lvl["bg"]]["size"][0])
	{
		for ($y = 0; $y < $h * 11 + $backgrounds[$lvl["bg"]]["size"][1]; $y += $backgrounds[$lvl["bg"]]["size"][1])
		{
			imagecopymerge($img, $backgrounds[$lvl["bg"]]["data"], $x + $backgrounds[$lvl["bg"]]["offset"][0], $y + $backgrounds[$lvl["bg"]]["offset"][1], 0, 0, $backgrounds[$lvl["bg"]]["size"][0], $backgrounds[$lvl["bg"]]["size"][1], 100);
		}
	}
	for ($row = 0; $row < $h; $row++)
	{
		for ($col = 0; $col < $w; $col++)
		{
			$chr = $lvl["map"][$row][$col];
			if ($chr === " ")
				continue;
			if ($chr === "S")
			{
				$has_left = $col > 0 && $lvl["map"][$row][$col - 1] === "S";
				$has_right = $col < $w - 1 && $lvl["map"][$row][$col + 1] === "S";
				$has_top = $row > 0 && $lvl["map"][$row - 1][$col] === "S";
				if ($has_top)
				{
					$chr = "M";
				}
				else
				{
					if ($has_left && !$has_right)
					{
						$chr = "R";
					}
					elseif (!$has_left && $has_right)
					{
						$chr = "L";
					}
					else
					{
						$chr = "C";
					}
				}
			}
			imagecopymerge($img, $sprites[$chr]["data"], $col * 11 + $sprites[$chr]["offset"][0], $row * 11 + $sprites[$chr]["offset"][1], 0, 0, $sprites[$chr]["size"][0], $sprites[$chr]["size"][1], 100);
		}
	}
	imagepng(imagescale($img, $w * 11 * 4, -1, IMG_NEAREST_NEIGHBOUR), sprintf("%02d.png", $l));
}
//print_r($levels);
?>