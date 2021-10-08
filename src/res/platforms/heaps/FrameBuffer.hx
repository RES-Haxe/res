package res.platforms.heaps;

import h2d.Tile;
import haxe.io.Bytes;
import hxd.Pixels;
import h2d.Bitmap;
import h2d.Scene;
import res.IFrameBuffer;

class FrameBuffer implements IFrameBuffer {
	final _width:Int;
	final _height:Int;
	final _indexBuffer:Array<Array<Int>>;
	final _palette:Palette;
	final _pixels:Pixels;

	public final bitmap:Bitmap;

	public function new(s2d:Scene, width:Int, height:Int, palette:Palette) {
		_width = width;
		_height = height;
		bitmap = new Bitmap(s2d);

		_pixels = new Pixels(width, height, Bytes.alloc(width * height * 4), ARGB);

		_indexBuffer = [for (line in 0...height) [for (col in 0...width) 0]];
		_palette = palette;
	}

	public var frameWidth(get, never):Int;

	public function get_frameWidth():Int
		return _width;

	public var frameHeight(get, never):Int;

	public function get_frameHeight():Int
		return _height;

	public function beginFrame() {}

	public function clear(index:Int) {
		final c = _palette.get(index).format(ARGB);

		for (line in 0...frameHeight)
			for (col in 0...frameWidth)
				_pixels.setPixel(col, line, c);
	}

	public function endFrame() {
		bitmap.tile = Tile.fromPixels(_pixels);
	}

	public function getIndex(x:Int, y:Int):Int {
		return _indexBuffer[y][x];
	}

	public function setIndex(x:Int, y:Int, index:Int) {
		_indexBuffer[y][x] = index;

		final c = _palette.get(index).format(ARGB);

		_pixels.setPixel(x, y, c);
	}
}
