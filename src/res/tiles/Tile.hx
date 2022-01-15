package res.tiles;

import haxe.io.Bytes;
import res.display.FrameBuffer;

using res.tools.BytesTools;

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

	public function yank(from:Bytes, srcWidth:Int, srcX:Int, srcY:Int) {
		for (scanline in 0...size) {
			final pos:Int = scanline * size;
			final srcPos:Int = (srcY * srcWidth) + (scanline * srcWidth) + srcX;

			indecies.blit(pos, from, srcPos, size);
		}
	}

	public static function drawTile(frameBuffer:FrameBuffer, tile:Tile, x:Int, y:Int, ?colorMap:ColorMap) {
		for (line in 0...tile.size) {
			for (col in 0...tile.size) {
				final index = tile.indecies.getxy(tile.size, col, line);
				if (index != 0)
					frameBuffer.setIndex(x + col, y + line, colorMap != null ? colorMap[index] : index);
			}
		}
	}
}
