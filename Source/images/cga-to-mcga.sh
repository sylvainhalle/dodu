#! /bin/bash
mkdir -p mcga
for f in $(find cga -type f -name "*.png" -o -name "*.gif"); do
	newf=${f//cga/mcga}
	newp=$(dirname $newf)
	mkdir -p $newp
	magick $f \
	  -fill '#00ff00' -opaque '#ffffff' \
	  -fill '#00aa00' -opaque '#ff00ff' \
	  -fill '#005500' -opaque '#00ffff' \
	  $newf
done