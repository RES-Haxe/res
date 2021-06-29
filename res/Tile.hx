package res;

import haxe.io.Bytes;

class Tile {
	var res:Res;
	var _indecies:Bytes;

	public var indecies(get, never):Bytes;

	function get_indecies():Bytes
		return _indecies;

	public function new(res:Res) {
		this.res = res;

		_indecies = Bytes.alloc(res.tileSize * res.tileSize);
	}

	public function yank(from:Bytes, srcWidth:Int, srcHeight:Int, srcX:Int, srcY:Int) {
		for (scanline in 0...res.tileSize) {
			final pos:Int = scanline * res.tileSize;
			final srcPos:Int = (srcY * srcWidth) + (scanline * srcWidth) + srcX;

			_indecies.blit(pos, from, srcPos, res.tileSize);
		}
	}
}
