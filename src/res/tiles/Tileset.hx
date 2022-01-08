package res.tiles;

import haxe.io.Bytes;

class Tileset {
	public final tileSize:Int;
	public final tiles:Array<Tile> = [];
	public final hTiles:Int;
	public final vTiles:Int;
	public final baseIndex:Int;

	public var numTiles(get, never):Int;

	function get_numTiles():Int
		return tiles.length;

	public function new(tileSize:Int, hTiles:Int, vTiles:Int, baseIndex:Int = 1) {
		this.tileSize = tileSize;
		this.hTiles = hTiles;
		this.vTiles = vTiles;
		this.baseIndex = baseIndex;
	}

	/**
		Get tile by index

		@param index Zero-based tile index
	 */
	public inline function get(index:Int):Tile
		return tiles[index];

	/**
		Add a Tile to set

		@param tile Tile to add
	 */
	public function addTile(tile:Tile):Tile {
		tiles.push(tile);
		return tile;
	}

	/**
		Create a tile from bytes

		@param data Bytes of indecies
	 */
	public function createTile(data:Bytes):Tile {
		if (data.length != tileSize * tileSize)
			throw 'Invalid data size for the tile ($tileSize x $tileSize = ${tileSize * tileSize} bytes expected)';
		return addTile(new Tile(tileSize, data));
	}

	/**
		Line by line

		Each byte is an index in a palette sample
	 */
	public function fromBytes(bytes:Bytes, srcWidth:Int, srcHeight:Int) {
		if (bytes.length != srcWidth * srcHeight)
			throw 'Invalid data size: expecting ${srcWidth * srcHeight}, got: ${bytes.length}';

		for (tileY in 0...Std.int(srcHeight / tileSize)) {
			for (tileX in 0...Std.int(srcWidth / tileSize)) {
				final tile = new Tile(tileSize);
				tile.yank(bytes, srcWidth, tileX * tileSize, tileY * tileSize);
				tiles.push(tile);
			}
		}
	}
}
