package res.platforms.js;

import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.ImageData;

class FrameBuffer implements IFrameBuffer {
	var _width:Int;
	var _height:Int;
	var _palette:Palette;
	var _indexBuffer:Array<Array<Int>>;
	var _imageData:ImageData;
	var _canvas:CanvasElement;
	var _ctx:CanvasRenderingContext2D;

	public var frameWidth(get, never):Int;

	public function get_frameWidth():Int {
		return _width;
	}

	public var frameHeight(get, never):Int;

	public function get_frameHeight():Int {
		return _height;
	}

	public function beginFrame() {}

	public function clear(index:Int) {
		final color = _palette.get(index);
		for (n in 0...(_width * _height)) {
			_imageData.data[n * 4] = color.r;
			_imageData.data[n * 4 + 1] = color.g;
			_imageData.data[n * 4 + 2] = color.b;
			_imageData.data[n * 4 + 3] = 255;
		}
	}

	public function endFrame() {
		_ctx.putImageData(_imageData, 0, 0);
	}

	public function getIndex(x:Int, y:Int):Int {
		return _indexBuffer[y][x];
	}

	public function setIndex(x:Int, y:Int, index:Int) {
		_indexBuffer[y][x] = index;
		final color = _palette.get(index);
		final pos = y * _width + x;

		_imageData.data[pos * 4] = color.r;
		_imageData.data[pos * 4 + 1] = color.g;
		_imageData.data[pos * 4 + 2] = color.b;
		_imageData.data[pos * 4 + 3] = 255;
	}

	public function new(width:Int, height:Int, palette:Palette, canvas:CanvasElement) {
		_canvas = canvas;
		_width = width;
		_height = height;
		_palette = palette;
		_indexBuffer = [for (_ in 0...height) [for (_ in 0...width) 0]];
		_imageData = new ImageData(width, height);
		_ctx = _canvas.getContext2d();
	}
}
