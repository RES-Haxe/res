package res.display;

import haxe.io.Bytes;
import res.tools.MathTools.wrapi;

class FrameBuffer {
	final _width:Int;
	final _height:Int;
	final _palette:Palette;
	final _indecies:Bytes;

	public var scrollX:Int = 0;
	public var scrollY:Int = 0;
	public var wrap:Bool = false;

	public var frameWidth(get, never):Int;

	public function get_frameWidth():Int {
		return _width;
	}

	public var frameHeight(get, never):Int;

	public function get_frameHeight():Int {
		return _height;
	}

	public function new(width:Int, height:Int, palette:Palette) {
		_width = width;
		_height = height;
		_palette = palette;
		_indecies = Bytes.alloc(width * height);
	}

	inline function checkBounds(x:Int, y:Int):Bool {
		return x >= 0 && y >= 0 && x < _width && y < _height;
	}

	private function setPixel(x:Int, y:Int, color:Color32) {}

	public function beginFrame() {}

	public function clear(index:Int) {
		_indecies.fill(0, _indecies.length, index);
	}

	public function endFrame() {}

	public function getIndex(x:Int, y:Int):Int {
		return _indecies.get(y * _width + x);
	}

	public function setIndex(x:Int, y:Int, index:Int) {
		x += scrollX;
		y += scrollY;

		if (wrap) {
			x = wrapi(x, _width);
			y = wrapi(y, _height);
		}

		if (checkBounds(x, y)) {
			_indecies.set(y * _width + x, index);
			setPixel(x, y, _palette.get(index));
		}
	}
}
