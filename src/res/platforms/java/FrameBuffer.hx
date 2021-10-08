package res.platforms.java;

import java.awt.image.BufferedImage;

class FrameBuffer implements IFrameBuffer {
	final _frameWidth:Int;
	final _frameHeight:Int;

	final _indexBuffer:Array<Array<Int>>;

	public final bufferedImage:BufferedImage;

	final palette:Palette;

	public function new(width:Int, height:Int, palette:Palette) {
		this._frameWidth = width;
		this._frameHeight = height;

		this._indexBuffer = [for (line in 0...height) [for (col in 0...width) 0]];

		bufferedImage = new BufferedImage(width, height, BufferedImage.TYPE_3BYTE_BGR);

		this.palette = palette;
	}

	public function beginFrame() {}

	public function clear(index:Int) {
		final c:Color = palette.get(index);
		final g = bufferedImage.getGraphics();

		g.setColor(new java.awt.Color(c.r, c.g, c.b));
		g.fillRect(0, 0, frameWidth, frameHeight);
	}

	public function endFrame() {}

	public function getIndex(x:Int, y:Int):Int {
		return _indexBuffer[y][x];
	}

	public function setIndex(x:Int, y:Int, index:Int) {
		_indexBuffer[y][x] = index;
		bufferedImage.setRGB(x, y, palette.get(index).format(RGB));
	}

	public var frameWidth(get, never):Int;

	public function get_frameWidth():Int {
		return _frameWidth;
	}

	public var frameHeight(get, never):Int;

	public function get_frameHeight():Int {
		return _frameHeight;
	}
}
