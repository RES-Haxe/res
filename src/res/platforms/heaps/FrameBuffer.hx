package res.platforms.heaps;

import h2d.Bitmap;
import h2d.Scene;
import h2d.Tile;
import haxe.io.Bytes;
import hxd.Pixels;

class FrameBuffer extends res.display.FrameBuffer {
	final _pixels:Pixels;
	final _bitmap:Bitmap;

	public function new(s2d:Scene, width:Int, height:Int, palette:Palette) {
		super(width, height, palette);

		_pixels = new Pixels(width, height, Bytes.alloc(width * height * 4), ARGB);
		_pixels.makeSquare(false);

		_bitmap = new Bitmap(Tile.fromPixels(_pixels), s2d);
	}

	override function setPixel(x:Int, y:Int, color:Color) {
		_pixels.setPixel(x, y, color.format(ARGB));
	}

	override public function clear(index:Int) {
		super.clear(index);

		final c = _palette.get(index).format(ARGB);

		for (line in 0...frameHeight)
			for (col in 0...frameWidth)
				_pixels.setPixel(col, line, c);
	}

	override public function endFrame() {
		_bitmap.tile.getTexture().uploadPixels(_pixels);
	}
}
