package res;

import haxe.io.Bytes;

class Tileset {
	var res:Res;

	public final tileSize:Int;
	public final tiles:Array<Tile> = [];
	public final hTiles:Int;
	public final vTiles:Int;

	public var numTiles(get, never):Int;

	function get_numTiles():Int
		return tiles.length;

	@:allow(res)
	private function new(tileSize:Int, hTiles:Int, vTiles:Int) {
		this.tileSize = tileSize;
		this.hTiles = hTiles;
		this.vTiles = vTiles;
	}

	public inline function get(index:Int):Tile
		return tiles[index];

	public function pushTile(data:Bytes) {
		final tile = new Tile(tileSize, data);
		tiles.push(tile);
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
