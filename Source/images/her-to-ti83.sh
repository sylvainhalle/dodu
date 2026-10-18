#! /bin/bash
mkdir -p mcga
for f in $(find her -type f -name "*.png" -o -name "*.gif"); do
	newf=${f//her/ti83}
	newp=$(dirname $newf)
	mkdir -p $newp
	magick $f \
	  -fill '#97a663' -opaque '#ffffff' \
	  $newf
done