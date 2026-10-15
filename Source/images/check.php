<?php

foreach (explode("\n", `find ega/ -type f -name "*.png"`) as $fn)
{
	
	$other_fn = str_replace("ega", "cga", $fn);
	//echo $other_fn;
	if (!file_exists($other_fn))
		echo $other_fn."\n";
}

?>