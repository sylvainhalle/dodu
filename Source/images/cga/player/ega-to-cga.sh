#! /bin/bash
find . -type f -name "*.png" | xargs -I {} magick {} \
  -fill '#ff00ff' -opaque '#aa0000' \
  -fill '#00ffff' -opaque '#aaffff' \
  -fill '#ffffff' -opaque '#ffaaaa' \
  -fill '#00ffff' -opaque '#aa5500' \
  -fill '#000000' -opaque '#5500aa' \
  ../{}