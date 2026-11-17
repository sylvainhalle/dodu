<?php
$LVL_FOLDER = "Source/images/ega/level/";
$BG_FOLDER = "Source/images/ega/backgrounds/";

// ------------------------------------------------------------
// Parse sections
// ------------------------------------------------------------

$sections = file_get_contents("Source/LevelMaps.bm");
$level_bgs = array();
$level_order = array();

$section_bgs = array(-1, -1);
$section_index = 0;

foreach (explode("\n", $sections) as $line)
{
    $line = trim($line);

    if (preg_match('/^Data "SECTION",/i', $line))
    {
        $section_index = 0;
        $section_bgs = array(-1, -1);
    }
    elseif (preg_match('/^Data "BACKGROUNDS",\s*(-?\d+),\s*(-?\d+)/i', $line, $matches))
    {
        $section_bgs = array((int)$matches[1], (int)$matches[2]);
    }
    elseif (preg_match('/^Data "LEVEL",\s*"([^"]+)"/i', $line, $matches))
    {
        $id = $matches[1];
        $level_bgs[$id] = $section_bgs[$section_index % 2];
        $level_order[] = $id;
        $section_index++;
    }
}

// ------------------------------------------------------------
// Parse individual maps
// ------------------------------------------------------------

$contents = file_get_contents("Source/LevelMaps.bi");
$maps = array();
$lvl = null;

foreach (explode("\n", $contents) as $line)
{
    $line = trim($line);

    // Numerical header
    if (preg_match('/^Data\s+(-?\d+),\s*(-?\d+),\s*(-?\d+),\s*(-?\d+)/i',
        $line, $matches))
    {
        if ($lvl !== null)
        {
            $lvl["bg"] = (int)$matches[1];
        }
        continue;
    }

    // String data
    if (!preg_match('/^Data\s+"([^"]*)"$/i', $line, $matches))
    {
        continue;
    }

    $str = $matches[1];

    if (strtolower($str) === "x")
    {
        // End of map
        if ($lvl !== null)
        {
            $maps[$lvl["id"]] = $lvl;
            $lvl = null;
        }
    }
    elseif ($lvl === null)
    {
        // Beginning of map: identifier
        $lvl = array(
            "id" => $str,
            "bg" => -1,
            "map" => array()
        );
    }
    else
    {
        // Topological data
        $lvl["map"][] = str_split($str);
    }
}

print_r($lvl);

// ------------------------------------------------------------
// Assemble levels and resolve inherited backgrounds
// ------------------------------------------------------------

$levels = array();

foreach ($level_order as $id)
{
    if (!isset($maps[$id]))
    {
        die("Unknown level: $id\n");
    }

    $lvl = $maps[$id];

    if ($lvl["bg"] === -1)
    {
        $lvl["bg"] = $level_bgs[$id];
    }

    if ($lvl["bg"] < 0)
    {
        die("No background defined for level: $id\n");
    }

    $levels[] = $lvl;
}

// ------------------------------------------------------------
// Load backgrounds
// ------------------------------------------------------------

$backgrounds = array(
    array("data" => imagecreatefromgif($BG_FOLDER . "Blue_1.gif"), "offset" => array(0, 0), "size" => array(20, 20)),
    array("data" => imagecreatefromgif($BG_FOLDER . "Blue_2.gif"), "offset" => array(0, 0), "size" => array(20, 20)),
    array("data" => imagecreatefromgif($BG_FOLDER . "Cards.gif"), "offset" => array(0, 0), "size" => array(20, 20)),
    array("data" => imagecreatefromgif($BG_FOLDER . "Cyan_1.gif"), "offset" => array(0, 0), "size" => array(20, 20)),
    array("data" => imagecreatefromgif($BG_FOLDER . "Cyan_2.gif"), "offset" => array(0, 0), "size" => array(20, 20)),
    array("data" => imagecreatefrompng($BG_FOLDER . "Snow_1.png"), "offset" => array(0, 0), "size" => array(20, 20)),
    array("data" => imagecreatefrompng($BG_FOLDER . "Pizza_1.png"), "offset" => array(0, 0), "size" => array(40, 40)),
    array("data" => imagecreatefrompng($BG_FOLDER . "Pizza_2.png"), "offset" => array(0, 0), "size" => array(40, 40)),
    array("data" => imagecreatefrompng($BG_FOLDER . "Digits.png"), "offset" => array(0, 0), "size" => array(20, 20)),
    array("data" => imagecreatefrompng($BG_FOLDER . "Snow_2b.png"), "offset" => array(0, 0), "size" => array(20, 20)),
);

// ------------------------------------------------------------
// Load sprites
// ------------------------------------------------------------

$sprites = array(
    "@" => array("data" => imagecreatefrompng($LVL_FOLDER . "BlockBlue.png"), "offset" => array(0, 0), "size" => array(11, 11)),
    "#" => array("data" => imagecreatefrompng($LVL_FOLDER . "BlockWhite.png"), "offset" => array(0, 0), "size" => array(11, 11)),
    "!" => array("data" => imagecreatefrompng($LVL_FOLDER . "Pole.png"), "offset" => array(1, -9), "size" => array(10, 20)),
    "c" => array("data" => imagecreatefrompng($LVL_FOLDER . "Cookie.png"), "offset" => array(2, 2), "size" => array(7, 7)),
    "m" => array("data" => imagecreatefrompng($LVL_FOLDER . "Mittens.png"), "offset" => array(-2, 2), "size" => array(15, 7)),
    "t" => array("data" => imagecreatefrompng($LVL_FOLDER . "Tuque.png"), "offset" => array(1, -3), "size" => array(10, 13)),
    "~" => array("data" => imagecreatefrompng($LVL_FOLDER . "Water.png"), "offset" => array(0, 0), "size" => array(11, 11)),
    "C" => array("data" => imagecreatefrompng($LVL_FOLDER . "Snow_C.png"), "offset" => array(0, -14), "size" => array(11, 25)),
    "L" => array("data" => imagecreatefrompng($LVL_FOLDER . "Snow_L.png"), "offset" => array(0, -14), "size" => array(11, 25)),
    "R" => array("data" => imagecreatefrompng($LVL_FOLDER . "Snow_R.png"), "offset" => array(0, -14), "size" => array(11, 25)),
    "M" => array("data" => imagecreatefrompng($LVL_FOLDER . "Snow_M.png"), "offset" => array(0, 0), "size" => array(11, 11)),
    "*" => array("data" => imagecreatefrompng($LVL_FOLDER . "Mark.png"), "offset" => array(0, 0), "size" => array(11, 11)),
    "f" => array("data" => imagecreatefrompng($LVL_FOLDER . "Coffee.png"), "offset" => array(1, 1), "size" => array(9, 9))
);

// Set sprite transparency
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

// ------------------------------------------------------------
// Render levels
// ------------------------------------------------------------

$solid = array("S", "@", "#");

for ($l = 0; $l < count($levels); $l++)
{
    $lvl = $levels[$l];
    $h = count($lvl["map"]);
    $w = count($lvl["map"][0]);

    echo sprintf(
        "Level %02d: %s (background %d)\n",
        $l, $lvl["id"], $lvl["bg"]
    );

    $img = imagecreatetruecolor($w * 11, $h * 11);

    // Draw tiled background
    $bg = $backgrounds[$lvl["bg"]];

    for ($x = 0; $x < $w * 11; $x += $bg["size"][0])
    {
        for ($y = 0; $y < $h * 11; $y += $bg["size"][1])
        {
            imagecopymerge(
                $img,
                $bg["data"],
                $x + $bg["offset"][0],
                $y + $bg["offset"][1],
                0, 0,
                $bg["size"][0],
                $bg["size"][1],
                100
            );
        }
    }

    // Draw level sprites
    for ($row = 0; $row < $h; $row++)
    {
        for ($col = 0; $col < $w; $col++)
        {
            $chr = $lvl["map"][$row][$col];

            if ($chr === " ")
            {
                continue;
            }

            // Determine snow slope
            if ($chr === "S")
            {
                $has_left = $col === 0 ||
                    in_array($lvl["map"][$row][$col - 1], $solid, true);

                $has_right = $col === $w - 1 ||
                    in_array($lvl["map"][$row][$col + 1], $solid, true);

                $has_top = $row === 0 ||
                    $lvl["map"][$row - 1][$col] === "S";

                if ($has_top)
                {
                    $chr = "M";
                }
                elseif ($has_left && !$has_right)
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

            // Check for unknown tiles
            if (!isset($sprites[$chr]))
            {
                echo "Unknown tile '$chr' at ($col, $row)\n";
                continue;
            }

            $sprite = $sprites[$chr];

            imagecopymerge(
                $img,
                $sprite["data"],
                $col * 11 + $sprite["offset"][0],
                $row * 11 + $sprite["offset"][1],
                0, 0,
                $sprite["size"][0],
                $sprite["size"][1],
                100
            );
        }
    }

    // Scale and save
    $scaled = imagescale(
        $img,
        $w * 11 * 4,
        -1,
        IMG_NEAREST_NEIGHBOUR
    );

    imagepng($scaled, sprintf("%02d.png", $l));

    imagedestroy($scaled);
    imagedestroy($img);
}

// ------------------------------------------------------------
// Write LaTeX
// ------------------------------------------------------------

//define("PX_PER_MM", 3.78);
define("PX_PER_MM", 2.5);
$PAGE_WIDTH = 342.9;
$PAGE_HEIGHT = 203.2;
$MARGIN_MM_TOP = 10;
$MARGIN_MM_OTHER = 2;

$pages = array();
$placed = array();
for ($l = 0; $l < count($levels); $l++)
{
	$level = $levels[$l];
	$h = count($level["map"]) * 11 / PX_PER_MM + $MARGIN_MM_TOP + $MARGIN_MM_OTHER;
	$w = count($level["map"][0]) * 11 / PX_PER_MM + 2 * $MARGIN_MM_OTHER;
	$p = findPosition($w, $h, $placed, $PAGE_WIDTH, $PAGE_HEIGHT);
	if ($p === null)
	{
		$pages[] = $placed;
		$placed = array();
		$l--;
		continue;
	}
	$p["id"] = $l;
	$placed[] = $p;
}
if (!empty($placed))
{
	$pages[] = $placed;
}
$html = <<<EOD
<!DOCTYPE html>
<html>
<head>
<style type="text/css">
body {
  margin: 0;
}
.number {
	size: 200%;
	font-family: sans-serif;
	font-weight: bold;
}
.level {
  position: absolute;
  padding-left: {$MARGIN_MM_OTHER}mm;
  box-sizing: border-box;
}
.level img {
    display: block;
}
.page {
    position: relative;
    width: {$PAGE_WIDTH}mm;
    height: {$PAGE_HEIGHT}mm;
    break-after: page;
}
</style>
<style type="text/css" media="screen">
</style>
<style type="text/css" media="print">
@page {
  size: legal landscape;
  margin: 0.25in;
}
.br {
  break-before: page;
}
</style>

<body>
EOD;

foreach ($pages as $placed)
{
	$html .= "<div class=\"page\">\n";
	foreach ($placed as $rectangle)
	{
		$html .= sprintf("<div class=\"level\" style=\"left: %fmm; top:%fmm; width: %fmm; height: %fmm;\"><span class=\"number\">%d</span><img src=\"%02d.png\" style=\"width:%fmm;height:%fmm\"></div>\n", 
			$rectangle["x"], 
			$rectangle["y"],  
			$rectangle["w"],
			$rectangle["h"],
			$rectangle["id"] + 1,
			$rectangle["id"],
			$rectangle["w"] - 2 * $MARGIN_MM_OTHER,
			$rectangle["h"] - $MARGIN_MM_TOP - $MARGIN_MM_OTHER,
			);
	}
	$html .= "</div>\n"; //<div class=\"br\"></div>\n";
}
$html .= <<<EOD
</div>
</body>
</html>
EOD;
file_put_contents("Levels.html", $html);

function intersects($a, $b)
{
    return
        $a["x"] < $b["x"] + $b["w"] &&
        $a["x"] + $a["w"] > $b["x"] &&
        $a["y"] < $b["y"] + $b["h"] &&
        $a["y"] + $a["h"] > $b["y"];
}

function findPosition($w, $h, $placed, $page_w, $page_h)
{
    $xs = array(0);
    $ys = array(0);

    foreach ($placed as $r)
    {
        $xs[] = $r["x"] + $r["w"];
        $ys[] = $r["y"] + $r["h"];
    }

    $xs = array_unique($xs);
    $ys = array_unique($ys);

    sort($xs, SORT_NUMERIC);
    sort($ys, SORT_NUMERIC);

    foreach ($ys as $y)
    {
        foreach ($xs as $x)
        {
            // Check page boundaries
            if ($x + $w > $page_w ||
                $y + $h > $page_h)
            {
                continue;
            }

            $candidate = array(
                "x" => $x,
                "y" => $y,
                "w" => $w,
                "h" => $h
            );

            // Check previously placed rectangles
            $fits = true;

            foreach ($placed as $r)
            {
                if (intersects($candidate, $r))
                {
                    $fits = false;
                    break;
                }
            }

            if ($fits)
            {
                return $candidate;
            }
        }
    }

    return null;
}
?>