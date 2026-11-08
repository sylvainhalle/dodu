<?php
require_once 'bmp.php';

ini_set('output_buffering', 'off');
ini_set('zlib.output_compression', '0');

header('Content-Type: multipart/x-mixed-replace; boundary=frame');
header('Cache-Control: no-store');

$IN_FORMAT = "jpg";
$OUT_FORMAT = "jpg";

while (ob_get_level()) {
    ob_end_clean();
}

set_time_limit(0);

while (!connection_aborted()) {
    //$imgdata_in = imagecreatefrombmpx('/dev/shm/dodu.' . $IN_FORMAT);
    $imgdata_in = file_get_contents('/dev/shm/dodu.' . $IN_FORMAT);
    if ($IN_FORMAT !== $OUT_FORMAT)
    {
    	ob_start();
    	imagepng($imgdata_in);
    	$imgdata = ob_get_contents();
    	ob_end_clean();
    }
    else
    {
    	$imgdata = $imgdata_in;
    }

    echo "--frame\r\n";
    echo "Content-Type: image/". $OUT_FORMAT . "\r\n";
    echo "Content-Length: " . strlen($imgdata) . "\r\n";
    //file_put_contents("/dev/shm/outtest.png", $imgdata);
    echo "\r\n";
    echo $imgdata;
    echo "\r\n";

    flush();
    usleep(40000); // 25 FPS
    //usleep(100000); // 25 FPS
}
