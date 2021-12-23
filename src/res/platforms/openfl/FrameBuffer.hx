package res.platforms.openfl;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class FrameBuffer implements FrameBuffer {
	var _width:Int;
	var _height:Int;
	var _palette:Palette;
	var _rect:Rectangle;
	var _indecies:Array<Array<Int>>;

	public final bitmapData:BitmapData;

	public var frameWidth(get, never):Int;

	public function get_frameWidth():Int {
		return _width;
	}

	public var frameHeight(get, never):Int;

	public function get_frameHeight():Int {
		return _height;
	}

	public function new(width:Int, height:Int, palette:Palette) {
		this._width = width;
		this._height = height;
		this._palette = palette;

		this._indecies = [for (_ in 0...height) [for (_ in 0...width) 0]];

		_rect = new Rectangle(0, 0, _width, height);

		bitmapData = new BitmapData(width, height, false, 0x0);
	}

	public function beginFrame() {
		bitmapData.lock();
	}

	public function clear(index:Int) {
		final color = _palette.get(index).format(ARGB);
		bitmapData.fillRect(_rect, color);
	}

	public function endFrame() {
		bitmapData.unlock();
	}

	public function getIndex(x:Int, y:Int):Int {
		return _indecies[y][x];
	}

	public function setIndex(x:Int, y:Int, index:Int) {
		_indecies[y][x] = index;
		final color = _palette.get(index).format(ARGB);
		bitmapData.setPixel(x, y, color);
	}
}
