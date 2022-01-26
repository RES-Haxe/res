package res.display;

import haxe.io.Bytes;
import res.tools.MathTools.wrapi;

abstract class FrameBuffer {
	public final width:Int;
	public final height:Int;

	final _palette:Palette;
	final _indecies:Bytes;

	public var scrollX:Int = 0;
	public var scrollY:Int = 0;
	public var wrap:Bool = false;

	public function new(width:Int, height:Int, palette:Palette) {
		this.width = width;
		this.height = height;
		_palette = palette;
		_indecies = Bytes.alloc(width * height);
	}

	inline function checkBounds(x:Int, y:Int):Bool {
		return x >= 0 && y >= 0 && x < width && y < height;
	}

	abstract private function setPixel(x:Int, y:Int, color:Color32):Void;

	public function beginFrame() {}

	public function clear(index:Int) {
		_indecies.fill(0, _indecies.length, index);
	}

	public function endFrame() {}

	public function getIndex(x:Int, y:Int):Int {
		return _indecies.get(y * width + x);
	}

	public function setIndex(x:Int, y:Int, index:Int) {
		x += scrollX;
		y += scrollY;

		if (wrap) {
			x = wrapi(x, width);
			y = wrapi(y, height);
		}

		if (checkBounds(x, y)) {
			_indecies.set(y * width + x, index);
			setPixel(x, y, _palette.get(index));
		}
	}
}
