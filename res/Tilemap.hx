package res;

import res.helpers.Funcs.wrapi;

class Tilemap implements Renderable {
	var res:Res;
	var map:Array<Array<Int>>;

	var tileset:Tileset;

	public final hTiles:Int;
	public final vTiles:Int;

	public var onScanline:Int->Void;

	public var paletteSample:PaletteSample;

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

	@:allow(res)
	private function new(res:Res, tileset:Tileset, hTiles:Int, vTiles:Int, ?paletteSample:PaletteSample) {
		this.res = res;
		this.tileset = tileset;
		this.hTiles = hTiles;
		this.vTiles = vTiles;
		this.paletteSample = paletteSample == null ? new PaletteSample(res.palette, [for (idx in 0...res.palette.colors.length) idx]) : paletteSample;
		this.map = [for (_ in 0...vTiles) [for (_ in 0...hTiles) 0]];
	}

	public function fill(tileIndex:Int) {
		for (line in map)
			for (index in 0...line.length)
				line[index] = tileIndex;
	}

	public function set(tileCol:Int, tileLine:Int, tileIndex:Int) {
		if (tileLine >= 0 && tileLine < map.length && tileCol >= 0 && tileCol < map[tileLine].length)
			map[tileLine][tileCol] = tileIndex;
		else
			throw 'Out of tile map bounds (col: $tileCol, line: $tileLine, size: $hTiles x $vTiles)';
	}

	public function render(frameBuffer:FrameBuffer) {
		for (screenScanline in 0...frameBuffer.frameHeight) {
			if (onScanline != null)
				onScanline(screenScanline);
			var tileScanline:Int = screenScanline + scrollY;
			var tileLineIndex:Int = Std.int(tileScanline / tileset.tileSize);

			if (tileLineIndex >= map.length)
				tileLineIndex = tileLineIndex % map.length;

			final inTileScanline:Int = tileScanline % tileset.tileSize;

			for (screenCol in 0...frameBuffer.frameWidth) {
				var tileCol:Int = screenCol + scrollX;
				var tileColIndex:Int = Std.int(tileCol / tileset.tileSize);

				if (tileColIndex >= map[tileLineIndex].length)
					tileColIndex = tileColIndex % map[tileLineIndex].length;

				final inTileCol:Int = tileCol % tileset.tileSize;

				final tileIndex = map[tileLineIndex][tileColIndex];

				if (tileIndex > 0 && tileIndex - 1 < tileset.numTiles) {
					final tile = tileset.get(tileIndex - 1);

					final tileColorIndex:Int = tile.indecies.get(inTileScanline * tileset.tileSize + inTileCol);

					if (tileColorIndex != 0) {
						final paletteColorIndex:Int = paletteSample.indecies[tileColorIndex - 1];

						frameBuffer.setIndex(screenCol, screenScanline, paletteColorIndex);
					}
				}
			}
		}
	}
}
