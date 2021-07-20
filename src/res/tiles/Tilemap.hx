package res.tiles;

import res.tools.MathTools.wrapi;

class Tilemap implements Renderable {
	var map:Array<Array<TilePlace>>;

	public final tileset:Tileset;

	public final hTiles:Int;
	public final vTiles:Int;

	public var onScanline:Int->Void;

	public var paletteIndecies:Array<Int>;

	public var pixelWidth(get, never):Int;

	function get_pixelWidth():Int
		return hTiles * tileset.tileSize;

	public var pixelHeight(get, never):Int;

	function get_pixelHeight():Int
		return vTiles * tileset.tileSize;

	public var scrollX(default, set):Int = 0;

	function set_scrollX(val:Int):Int {
		return scrollX = wrapi(val, pixelWidth);
	}

	public var scrollY(default, set):Int = 0;

	function set_scrollY(val:Int):Int {
		return scrollY = wrapi(val, pixelHeight);
	}

	public function new(tileset:Tileset, hTiles:Int, vTiles:Int, ?paletteIndecies:Array<Int>) {
		this.tileset = tileset;
		this.hTiles = hTiles;
		this.vTiles = vTiles;
		this.paletteIndecies = paletteIndecies;
		this.map = [for (_ in 0...vTiles) [for (_ in 0...hTiles)
			({
				index:0, flipY:false, flipX:false
			})]];
	}

	public function fill(tileIndex:Int) {
		for (line in map)
			for (index in 0...line.length)
				line[index].index = tileIndex;
	}

	inline function inBounds(tileCol:Int, tileLine:Int):Bool {
		return (tileLine >= 0 && tileLine < map.length && tileCol >= 0 && tileCol < map[tileLine].length);
	}

	public function get(tileCol:Int, tileLine:Int):Null<TilePlace> {
		if (inBounds(tileCol, tileLine))
			return map[tileLine][tileCol];
		else
			return null;
	}

	public function set(tileCol:Int, tileLine:Int, tileIndex:Int, flipX:Bool = false, flipY:Bool = false) {
		if (inBounds(tileCol, tileLine)) {
			map[tileLine][tileCol].index = tileIndex;
			map[tileLine][tileCol].flipX = flipX;
			map[tileLine][tileCol].flipY = flipY;
		} else
			throw 'Out of tile map bounds (col: $tileCol, line: $tileLine, size: $hTiles x $vTiles)';
	}

	public function render(frameBuffer:FrameBuffer) {
		for (screenScanline in 0...frameBuffer.frameHeight) {
			if (onScanline != null)
				onScanline(screenScanline);

			var tileScanline:Int = screenScanline + scrollY;
			var tileLineIndex:Int = Math.floor(tileScanline / tileset.tileSize);

			if (tileLineIndex >= map.length)
				tileLineIndex = tileLineIndex % map.length;

			final inTileScanline:Int = tileScanline % tileset.tileSize;

			for (screenCol in 0...frameBuffer.frameWidth) {
				var tileCol:Int = screenCol + scrollX;
				var tileColIndex:Int = Math.floor(tileCol / tileset.tileSize);

				if (tileColIndex >= map[tileLineIndex].length)
					tileColIndex = tileColIndex % map[tileLineIndex].length;

				final inTileCol:Int = tileCol % tileset.tileSize;

				final tilePlace = map[tileLineIndex][tileColIndex];

				if (tilePlace.index > 0 && tilePlace.index - 1 < tileset.numTiles) {
					final tile = tileset.get(tilePlace.index - 1);

					final ftx = tilePlace.flipX ? (tileset.tileSize - 1) - inTileCol : inTileCol;
					final fty = tilePlace.flipY ? (tileset.tileSize - 1) - inTileScanline : inTileScanline;

					final tileColorIndex:Int = tile.indecies.get(fty * tileset.tileSize + ftx);

					if (tileColorIndex != 0) {
						final paletteColorIndex:Int = paletteIndecies == null ? tileColorIndex : paletteIndecies[tileColorIndex - 1];

						frameBuffer.setIndex(screenCol, screenScanline, paletteColorIndex);
					}
				}
			}
		}
	}
}
