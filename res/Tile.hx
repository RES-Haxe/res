package res;

import haxe.io.Bytes;

class Tile {
	public final size:Int;

	var _indecies:Bytes;

	public var indecies(get, never):Bytes;

	function get_indecies():Bytes
		return _indecies;

	public function new(tileSize:Int) {
		size = tileSize;

		_indecies = Bytes.alloc(size * size);
	}

	public function yank(from:Bytes, srcWidth:Int, srcHeight:Int, srcX:Int, srcY:Int) {
		for (scanline in 0...size) {
			final pos:Int = scanline * size;
			final srcPos:Int = (srcY * srcWidth) + (scanline * srcWidth) + srcX;

			_indecies.blit(pos, from, srcPos, size);
		}
	}
}
