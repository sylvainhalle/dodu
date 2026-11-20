.PHONY: levelmaps normalize-sprites
levelmaps:
	@rm -f Source/LevelMaps.bi
	@echo 'LevelData:' >> Source/LevelMaps.bi
	@find Source/levels -type f -name *.bm | xargs -I {} cat {} >> Source/LevelMaps.bi
	@echo '' >> Source/LevelMaps.bi
	@echo 'Data "X"' >> Source/LevelMaps.bi
	@sed -i "s/'/\n'/g" Source/LevelMaps.bi
	@php drawlevels.php

normalize-sprites:
	find Source/images/ega -name '*.png' \
	    -exec mogrify -alpha off \
	    -transparent '#343434' \
	    -define png:color-type=3 {} +


