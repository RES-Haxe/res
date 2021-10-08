package res.tools;

class ResolutionTools {
	public static function pixelSize(resolution:Resolution):{width:Int, height:Int} {
		switch (resolution) {
			case TILES(tileSize, hTiles, vTiles):
				return {
					width: tileSize * hTiles,
					height: tileSize * vTiles
				};
			case PIXELS(width, height):
				return {
					width: width,
					height: height
				};
		}
	}
}
