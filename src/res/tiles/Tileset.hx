package res.tiles;

import res.display.Bitmap;
import res.display.FrameBuffer;
import haxe.io.Bytes;

class Tileset {
	public final tileWidth:Int;
	public final tileHeight:Int;

	var _tilesData:Bytes;

	public var tilesData(get, never):Bytes;

	function get_tilesData()
		return _tilesData;

	/**
		Size of a tile in bytes (width x height)
	 */
	public var tileSize(get, never):Int;

	function get_tileSize()
		return tileWidth * tileHeight;

	public var numTiles(get, never):Int;

	function get_numTiles():Int
		return Std.int(_tilesData.length / tileSize);

	public function new(tileWidth:Int, tileHeight:Int, ?tilesData:Bytes) {
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;

		if (tilesData != null) {
			if (tilesData.length % (tileWidth * tileHeight) == 0)
				_tilesData = tilesData;
			else
				throw 'Invalid tile data size';
		} else {
			_tilesData = Bytes.alloc(0);
		}
	}

	/**
		Get a color index in a particular x/y position of a particular tile

		@param tileIndex
		@param x 
		@param y
	 */
	public function getIndex(tileIndex:Int, x:Int, y:Int):Int
		return _tilesData.get(tileIndex * tileSize + y * tileWidth + x);

	public function getTileData(tileIndex:Int)
		return _tilesData.sub(tileIndex * tileSize, tileSize);

	/**
		Add a tile to set

		@param data Raw tile data
	 */
	public function addTile(data:Bytes) {
		if (data.length == tileWidth * tileHeight) {
			final newData = Bytes.alloc(_tilesData.length + (tileWidth * tileHeight));
			newData.blit(0, _tilesData, 0, _tilesData.length);
			newData.blit(_tilesData.length, data, 0, data.length);
			_tilesData = newData;
		} else
			throw 'Invalid tile data size';
	}

	public function drawTile(surface:Bitmap, tileIndex:Int, x:Int, y:Int, ?colorMap:IndexMap)
		return surface.raster(x, y, _tilesData, tileIndex * tileSize, tileWidth, tileHeight, colorMap);
}
