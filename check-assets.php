<?php
$root = __DIR__ . "/Source/images";
$reference = "ega";
$modes = ["cga", "mcga", "her"];

function getAssets(string $directory): array
{
    $assets = [];

    if (!is_dir($directory)) {
        return $assets;
    }

    $iterator = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator(
            $directory,
            FilesystemIterator::SKIP_DOTS
        )
    );

    foreach ($iterator as $file) {
        if (!$file->isFile()) {
            continue;
        }

        if (strtolower($file->getExtension()) !== "png") {
            continue;
        }

        $relative = substr(
            $file->getPathname(),
            strlen($directory) + 1
        );

        $assets[] = $relative;
    }

    sort($assets);
    return $assets;
}

$referenceAssets = getAssets("$root/$reference");
$missingCount = array_fill_keys($modes, 0);

printf("%-45s", "Asset");
foreach ($modes as $mode) {
    printf(" %-6s", strtoupper($mode));
}
echo "\n", str_repeat("-", 70), "\n";

foreach ($referenceAssets as $asset) {
    $missing = [];

    foreach ($modes as $mode) {
        $exists = is_file("$root/$mode/$asset");

        if (!$exists) {
            $missingCount[$mode]++;
            $missing[$mode] = true;
        }
    }

    // Only display incomplete assets
    if (!$missing) {
        continue;
    }

    printf("%-45s", $asset);

    foreach ($modes as $mode) {
        printf(
            " %-6s",
            isset($missing[$mode]) ? "MISSING" : "OK"
        );
    }

    echo "\n";
}

echo "\nSummary:\n";

foreach ($modes as $mode) {
    printf(
        "  %-5s: %d / %d missing\n",
        strtoupper($mode),
        $missingCount[$mode],
        count($referenceAssets)
    );
}
?>