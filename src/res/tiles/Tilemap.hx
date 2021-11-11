package res.tiles;

import res.display.Renderable;
import res.tools.MathTools.wrapf;

using Math;

typedef ScanlineFuncCallback = ?Float->?Float->Void;
typedef ScanlineFunc = Int->ScanlineFuncCallback->Void;

class Tilemap extends Renderable {
	var map:Array<Array<TilePlace>> = [[]];

	public final tileset:Tileset;

	public var hTiles:Int;
	public var vTiles:Int;

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
		this.colorMap = colorMap;

		resize(hTiles, vTiles);
	}

	public function clear() {
		for (line in 0...vTiles) {
			if (map[line] == null)
				map[line] = [for (_ in 0...hTiles) null];

			for (col in 0...hTiles) {
				empty(col, line);
			}
		}
	}

	public function clone():Tilemap {
		var cloned = new Tilemap(tileset, hTiles, vTiles, colorMap);
		for (line in 0...vTiles) {
			for (col in 0...hTiles) {
				final t = get(col, line);

				cloned.set(col, line, t.index, t.flipX, t.flipY, t.rot90cw, t.data);
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
		return (tileLine >= 0 && tileLine < vTiles && tileCol >= 0 && tileCol < hTiles);
	}

	public function get(tileCol:Int, tileLine:Int):Null<TilePlace> {
		if (inBounds(tileCol, tileLine))
			return map[tileLine][tileCol];
		else
			return null;
	}

	public function empty(tileCol:Int, tileLine:Int) {
		map[tileLine][tileCol] = null;
	}

	public function place(x:Int, y:Int, place:TilePlace) {
		if (inBounds(x, y)) {
			map[y][x] = place;
		} else
			throw 'Out of tile map bounds (col: $x, line: $y, size: $hTiles x $vTiles)';
	}

	public function set(tileCol:Int, tileLine:Int, tileIndex:Int, flipX:Bool = false, flipY:Bool = false, rot90cw:Bool = false, ?colorMap:Array<Int>,
			?data:Dynamic) {
		place(tileCol, tileLine, {
			index: tileIndex,
			flipX: flipX,
			flipY: flipY,
			rot90cw: rot90cw,
			colorMap: colorMap,
			data: data
		});
	}

	public function resize(newWidth:Int, ?newHeight:Int) {
		hTiles = newWidth;
		vTiles = newHeight == null ? vTiles : newHeight;

		map.resize(vTiles);

		for (i in 0...map.length) {
			if (map[i] == null)
				map[i] = [for (_ in 0...hTiles) null];
		}
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

		@param frameBuffer FrameBuffer to render to
		@param tilemap Tilemap to render
		@param x screen X corrdinate
		@param y screen Y coordinate
		@param width width of the window to render (framWidth by default)
		@param height height of the window to render (framHeight by default)
		@param scrollX
		@param scrollY
		@param wrapping
		@param scanlineFunc
	 */
	public static function drawTilemap(frameBuffer:IFrameBuffer, tilemap:Tilemap, ?x:Int = 0, ?y:Int = 0, ?width:Int, ?height:Int, ?scrollX:Float = 0,
			?scrollY:Float = 0, ?wrapping:Bool = true, ?scanlineFunc:ScanlineFunc) {
		if (width == null)
			width = frameBuffer.frameWidth;
		if (height == null)
			height = frameBuffer.frameHeight;

		for (line in 0...height) {
			final screenScanline = y + line;

			if (screenScanline >= 0 && screenScanline < frameBuffer.frameHeight) {
				if (scanlineFunc != null) {
					scanlineFunc(line, (?sx:Float, ?sy:Float) -> {
						if (sx != null)
							scrollX = sx;
						if (sy != null)
							scrollY = sy;
					});
				}

				final tileScanline:Int = (line + wrapf(scrollY, tilemap.pixelHeight)).floor();
				var tileLineIndex:Int = (tileScanline / tilemap.tileset.tileSize).floor();

				if (tileLineIndex >= tilemap.vTiles)
					tileLineIndex = tileLineIndex % tilemap.vTiles;

				final inTileScanline:Int = tileScanline % tilemap.tileset.tileSize;

				for (col in 0...width) {
					final screenCol = x + col;

					if (screenCol >= 0 && screenCol < frameBuffer.frameWidth) {
						final tileCol:Int = (col + wrapf(scrollX, tilemap.pixelWidth)).floor();
						var tileColIndex:Int = (tileCol / tilemap.tileset.tileSize).floor();

						if (tileColIndex >= tilemap.hTiles)
							tileColIndex = tileColIndex % tilemap.hTiles;

						final inTileCol:Int = tileCol % tilemap.tileset.tileSize;

						final tilePlace = tilemap.get(tileColIndex, tileLineIndex);

						if (tilePlace != null && tilePlace.index > 0 && tilePlace.index - 1 < tilemap.tileset.numTiles) {
							final tileColorIndex:Int = tilemap.readTilePixel(tileColIndex, tileLineIndex, inTileCol, inTileScanline);
							final paletteColorIndex:Int = tilePlace.colorMap != null ? tilePlace.colorMap[tileColorIndex] : tilemap.colorMap == null ? tileColorIndex : tilemap.colorMap[tileColorIndex];

							if (paletteColorIndex != 0)
								frameBuffer.setIndex(screenCol, screenScanline, paletteColorIndex);
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
	override public function render(frameBuffer:IFrameBuffer)
		drawTilemap(frameBuffer, this, 0, 0, frameBuffer.frameWidth, frameBuffer.frameHeight, scrollX, scrollY, true, scanlineFunc);
}
