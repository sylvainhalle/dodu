<?php
$line_cnt = 0;
foreach (explode("\n", file_get_contents("Source/Passwords.bm")) as $line)
{
	if (substr($line, 0, 4) !== "Data")
		continue;
	$cards = explode(",", substr($line, 4));
	$column = $line_cnt % 4;
	$level = floor($line_cnt / 4);
	for ($i = 0; $i < 4; $i++)
	{
		$number = $cards[$i] % 13;
		$suit = floor($cards[$i] / 13);
		echo html_entity_decode(sprintf("&#x%s;", print_card($number, $suit)), 0, 'UTF-8');
	}
	if ($column == 3)
		echo "\n";
	else
		echo "\t";
	$line_cnt++;
}

function print_card($number, $suit)
{
	//return "$number$suit ";
	$out = "1f0";
	if ($suit == 0) // hearts
		$out .= "b";
	elseif ($suit == 1) // spades
		$out .= "a";
	elseif ($suit == 2) // diamonds
		$out .= "c";
	elseif ($suit == 3) // clubs
		$out .= "d";
	if ($number < 11)
		$out .= dechex($number + 1);
	else
		$out .= dechex($number + 2);
	return $out;
}
?>