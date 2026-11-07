<?php
header('Content-Type: multipart/x-mixed-replace; boundary=frame');
header('Cache-Control: no-store');

while (ob_get_level()) {
    ob_end_clean();
}

set_time_limit(0);

while (!connection_aborted()) {
    $jpeg = file_get_contents('/dev/shm/dodu.jpg');
    if ($jpeg === false || substr($jpeg, -2) !== "\xFF\xD9") {
    error_log("Incomplete JPEG detected");
    continue;
    }

    echo "--frame\r\n";
    echo "Content-Type: image/jpeg\r\n";
    echo "Content-Length: " . strlen($jpeg) . "\r\n";
    echo "\r\n";
    echo $jpeg;
    echo "\r\n";

    flush();
    usleep(40000); // 25 FPS
}
