package res;

import haxe.io.Bytes;

class Tile {
	public final size:Int;

	public final indecies:Bytes;

	public function new(tileSize:Int, ?data:Bytes) {
		size = tileSize;

		indecies = data != null ? data : Bytes.alloc(size * size);
	}

	public function fill(index:Int) {
		indecies.fill(0, size * size, index);
	}

	public function setIndex(x:Int, y:Int, index:Int) {
		indecies.set(size * y + x, index);
	}

	public function yank(from:Bytes, srcWidth:Int, srcHeight:Int, srcX:Int, srcY:Int) {
		for (scanline in 0...size) {
			final pos:Int = scanline * size;
			final srcPos:Int = (srcY * srcWidth) + (scanline * srcWidth) + srcX;

			indecies.blit(pos, from, srcPos, size);
		}
	}
}
