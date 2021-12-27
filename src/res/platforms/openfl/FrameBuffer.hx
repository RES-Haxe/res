package res.platforms.openfl;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class FrameBuffer extends res.display.FrameBuffer {
	var _rect:Rectangle;

	public final bitmapData:BitmapData;

	public function new(width:Int, height:Int, palette:Palette) {
		super(width, height, palette);

		_rect = new Rectangle(0, 0, _width, height);

		bitmapData = new BitmapData(width, height, false, 0x0);
	}

	override public function beginFrame() {
		bitmapData.lock();
	}

	override public function clear(index:Int) {
		final color = _palette.get(index).format(ARGB);
		bitmapData.fillRect(_rect, color);
	}

	override public function endFrame() {
		bitmapData.unlock();
	}

	override function setPixel(x:Int, y:Int, color:Color) {
		bitmapData.setPixel(x, y, color.format(ARGB));
	}
	/*
		public function setIndex(x:Int, y:Int, index:Int) {
			_indecies[y][x] = index;
			final color = _palette.get(index).format(ARGB);
			bitmapData.setPixel(x, y, color);
		}
	 */
}
