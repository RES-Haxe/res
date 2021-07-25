package res.tiles;

import haxe.io.Bytes;

class Tileset {
	public final tileSize:Int;
	public final tiles:Array<Tile> = [];
	public final hTiles:Int;
	public final vTiles:Int;

	public var numTiles(get, never):Int;

	function get_numTiles():Int
		return tiles.length;

	public function new(tileSize:Int, hTiles:Int, vTiles:Int) {
		this.tileSize = tileSize;
		this.hTiles = hTiles;
		this.vTiles = vTiles;
	}

	/**
		Create an array of indecies for the tiles
	 */
	public function getIndecies():Array<Int> {
		return [for (index in 1...tiles.length + 1) index];
	}

	public inline function get(index:Int):Tile
		return tiles[index];

	public function pushTile(?data:Bytes):Tile {
		if (data.length != tileSize * tileSize)
			throw 'Invalid data sise for the tile ($tileSize x $tileSize = ${tileSize * tileSize} bytes expected)';
		final tile = new Tile(tileSize, data);
		tiles.push(tile);
		return tile;
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
				tile.yank(bytes, srcWidth, srcHeight, tileX * tileSize, tileY * tileSize);
				tiles.push(tile);
			}
		}
	}
}
