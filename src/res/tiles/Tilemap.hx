package res.tiles;

import res.display.Renderable;
import res.tools.MathTools.wrap;

using Math;

typedef ScanlineFuncCallback = ?Float->?Float->Void;
typedef ScanlineFunc = Int->ScanlineFuncCallback->Void;

class Tilemap extends Renderable {
	var map:Array<Array<TilePlace>>;

	public final tileset:Tileset;

	public final hTiles:Int;
	public final vTiles:Int;

	public var scanlineFunc:ScanlineFunc;

	public var colorMap:Array<Int> = null;

	public var indexMap:Array<Int> = null;

	public var pixelWidth(get, never):Int;

	function get_pixelWidth():Int
		return hTiles * tileset.tileSize;

	public var pixelHeight(get, never):Int;

	function get_pixelHeight():Int
		return vTiles * tileset.tileSize;

	public var scrollX:Float = 0;
	public var scrollY:Float = 0;

	public function new(tileset:Tileset, hTiles:Int, vTiles:Int, ?colorMap:Array<Int>) {
		this.tileset = tileset;
		this.hTiles = hTiles;
		this.vTiles = vTiles;
		this.colorMap = colorMap;
		this.map = [for (_ in 0...vTiles) [for (_ in 0...hTiles)
			({
				index:0, rot90cw:false, flipY:false, flipX:false
			})]];
	}

	public function clear() {
		for (line in 0...vTiles) {
			for (col in 0...hTiles) {
				map[line][col].index = 0;
				map[line][col].flipX = false;
				map[line][col].flipY = false;
				map[line][col].rot90cw = false;
			}
		}
	}

	public function clone():Tilemap {
		var cloned = new Tilemap(tileset, hTiles, vTiles, colorMap);
		for (line in 0...vTiles) {
			for (col in 0...hTiles) {
				final t = get(col, line);

				cloned.set(col, line, t.index, t.flipX, t.flipY, t.rot90cw);
			}
		}

		return cloned;
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

	public function set(tileCol:Int, tileLine:Int, tileIndex:Int, flipX:Bool = false, flipY:Bool = false, rot90cw:Bool = false) {
		if (inBounds(tileCol, tileLine)) {
			map[tileLine][tileCol].index = tileIndex;
			map[tileLine][tileCol].flipX = flipX;
			map[tileLine][tileCol].flipY = flipY;
			map[tileLine][tileCol].rot90cw = rot90cw;
		} else
			throw 'Out of tile map bounds (col: $tileCol, line: $tileLine, size: $hTiles x $vTiles)';
	}

	/**
		Get pixel from a tile to render

		@param tx tile column
		@param ty tile row
		@param fx x pixel in tile without rotation nor flipping
		@param fy y pixel in tile without rotation nor flipping
	 */
	function readTilePixel(tx:Int, ty:Int, fx:Int, fy:Int):Int {
		final tile = map[ty][tx];
		final rfx = tile.rot90cw ? fy : fx;
		final rfy = tile.rot90cw ? tileset.tileSize - 1 - fx : fy;

		final ffx = tile.flipX ? tileset.tileSize - 1 - rfx : rfx;
		final ffy = tile.flipY ? tileset.tileSize - 1 - rfy : rfy;

		final tileIndex = indexMap == null ? tile.index - 1 : indexMap[tile.index - 1] - 1;

		return tileset.get(tileIndex).indecies.get(ffy * tileset.tileSize + ffx);
	}

	/**
		Draw a tilemap

		@param tilemap Tilemap to render
		@param frameBuffer FrameBuffer to render to
		@param x screen X corrdinate
		@param y screen Y coordinate
		@param width width of the window to render (framWidth by default)
		@param height height of the window to render (framHeight by default)
		@param scrollX
		@param scrollY
		@param wrapping
		@param scanlineFunc
	 */
	public static function drawTilemap(tilemap:Tilemap, frameBuffer:FrameBuffer, ?x:Int = 0, ?y:Int = 0, ?width:Int, ?height:Int, ?scrollX:Float = 0,
			?scrollY:Float = 0, ?wrapping:Bool = true, ?scanlineFunc:ScanlineFunc) {
		if (width == null)
			width = frameBuffer.frameWidth;
		if (height == null)
			height = frameBuffer.frameHeight;

		for (line in 0...height) {
			final screenScanline = y + line;

			if (screenScanline >= 0 && screenScanline < frameBuffer.frameHeight) {
				if (scanlineFunc != null)
					scanlineFunc(line, (?sx:Float, ?sy:Float) -> {
						if (sx != null)
							scrollX = sx;
						if (sy != null)
							scrollY = sy;
					});

				final tileScanline:Int = (line + wrap(scrollY, tilemap.pixelHeight)).floor();
				var tileLineIndex:Int = (tileScanline / tilemap.tileset.tileSize).floor();

				if (tileLineIndex >= tilemap.vTiles)
					tileLineIndex = tileLineIndex % tilemap.vTiles;

				final inTileScanline:Int = tileScanline % tilemap.tileset.tileSize;

				for (col in 0...width) {
					final screenCol = x + col;

					if (screenCol >= 0 && screenCol < frameBuffer.frameWidth) {
						final tileCol:Int = (col + wrap(scrollX, tilemap.pixelWidth)).floor();
						var tileColIndex:Int = (tileCol / tilemap.tileset.tileSize).floor();

						if (tileColIndex >= tilemap.hTiles)
							tileColIndex = tileColIndex % tilemap.hTiles;

						final inTileCol:Int = tileCol % tilemap.tileset.tileSize;

						final tilePlace = tilemap.get(tileColIndex, tileLineIndex);

						if (tilePlace != null && tilePlace.index > 0 && tilePlace.index - 1 < tilemap.tileset.numTiles) {
							final tileColorIndex:Int = tilemap.readTilePixel(tileColIndex, tileLineIndex, inTileCol, inTileScanline);

							if (tileColorIndex != 0) {
								final paletteColorIndex:Int = tilemap.colorMap == null ? tileColorIndex : tilemap.colorMap[tileColorIndex - 1];

								frameBuffer.setIndex(screenCol, screenScanline, paletteColorIndex);
							}
						}
					}
				}
			}
		}
	}

	/**
		Render the tilemap

		@param frameBuffer Frame buffer to render at
	 */
	override public function render(frameBuffer:FrameBuffer)
		drawTilemap(this, frameBuffer, 0, 0, frameBuffer.frameWidth, frameBuffer.frameHeight, scrollX, scrollY, true);
}
