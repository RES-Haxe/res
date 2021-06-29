package res;

import haxe.io.Bytes;

class Tilemap {
	var res:Res;
	var map:Array<Array<Int>>;

	var tileset:Tileset;

	var hTiles:Int;
	var vTiles:Int;

	public var onScanline:Int->Void;

	public var paletteSample:PaletteSample;

	public var pixelWidth(get, never):Int;

	function get_pixelWidth():Int
		return hTiles * res.tileSize;

	public var pixelHeight(get, never):Int;

	function get_pixelHeight():Int
		return vTiles * res.tileSize;

	public var scrollX(default, set):Int = 0;

	function set_scrollX(val:Int):Int {
		if (val < 0)
			val = pixelWidth + (val % pixelWidth);

		if (val > pixelWidth)
			val = val % pixelWidth;

		return scrollX = val;
	}

	public var scrollY(default, set):Int = 0;

	function set_scrollY(val:Int):Int {
		if (val < 0)
			val = pixelHeight + (val % pixelHeight);

		if (val > pixelHeight)
			val = val % pixelHeight;

		return scrollY = val;
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
			throw 'Out of tile map bounds';
	}

	public function render(frameBuffer:Bytes, frameWidth:Int, frameHeight:Int) {
		for (screenScanline in 0...frameHeight) {
			if (onScanline != null)
				onScanline(screenScanline);
			var tileScanline:Int = screenScanline + scrollY;
			var tileLineIndex:Int = Std.int(tileScanline / res.tileSize);

			if (tileLineIndex >= map.length)
				tileLineIndex = tileLineIndex % map.length;

			final inTileScanline:Int = tileScanline % res.tileSize;

			for (screenCol in 0...frameWidth) {
				var tileCol:Int = screenCol + scrollX;
				var tileColIndex:Int = Std.int(tileCol / res.tileSize);

				if (tileColIndex >= map[tileLineIndex].length)
					tileColIndex = tileColIndex % map[tileLineIndex].length;

				final inTileCol:Int = tileCol % res.tileSize;

				final tileIndex = map[tileLineIndex][tileColIndex];

				if (tileIndex > 0 && tileIndex - 1 < tileset.numTiles) {
					final tile = tileset.get(tileIndex - 1);

					final pixelPos:Int = (screenScanline * frameWidth + screenCol) * res.pixelSize;

					final paletteIndex:Int = tile.indecies.get(inTileScanline * res.tileSize + inTileCol);

					if (paletteIndex != 0) {
						final sampleIndex:Int = paletteIndex - 1;

						final color:Int = paletteSample.get(sampleIndex).format(ARGB);

						frameBuffer.setInt32(pixelPos, color);
					}
				}
			}
		}
	}
}
