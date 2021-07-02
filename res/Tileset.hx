package res;

import format.png.Reader;
import format.png.Tools;
import haxe.io.Bytes;
import haxe.io.BytesInput;

class Tileset {
	var res:Res;

	public final tiles:Array<Tile> = [];

	public var numTiles(get, never):Int;

	function get_numTiles():Int
		return tiles.length;

	@:allow(res)
	private function new(res:Res) {
		this.res = res;
	}

	public inline function get(index:Int):Tile
		return tiles[index];

	/**
		Line by line

		Each byte is an index in a palette sample
	 */
	public function fromBytes(bytes:Bytes, srcWidth:Int, srcHeight:Int) {
		if (bytes.length != srcWidth * srcHeight)
			throw 'Invalid data size: expecting ${srcWidth * srcHeight}, got: ${bytes.length}';

		for (tileY in 0...Std.int(srcHeight / res.tileSize)) {
			for (tileX in 0...Std.int(srcWidth / res.tileSize)) {
				final tile = new Tile(res);
				tile.yank(bytes, srcWidth, srcHeight, tileX * res.tileSize, tileY * res.tileSize);
				tiles.push(tile);
			}
		}
	}

	public function loadPNG(bytes:Bytes) {
		// FIXME: The code is horrible. Need to rewrite
		var pngReader = new Reader(new BytesInput(bytes));
		var pngData = pngReader.read();

		var header = Tools.getHeader(pngData);
		var palette = Tools.getPalette(pngData);

		var indexBytes = Bytes.alloc(header.width * header.height);

		var colors:Array<Int> = [];

		var bi = new BytesInput(palette);

		for (_ in 0...Std.int(bi.length / 3)) {
			var col = Color.fromInt24(bi.readUInt24());

			colors.push(Color.fromARGB(col.a, col.b, col.g, col.r));
		}

		var pixels = new BytesInput(Tools.extract32(pngData));

		for (n in 0...Std.int(pixels.length / 4)) {
			var px = pixels.readInt32();

			var index = colors.indexOf(px);

			indexBytes.set(n, index == -1 ? 0 : index);
		}

		fromBytes(indexBytes, header.width, header.height);
	}
}
