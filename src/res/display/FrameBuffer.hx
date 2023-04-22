package res.display;

import res.tools.MathTools.wrap;

class FrameBuffer extends Bitmap {
	public var scrollX:Int = 0;
	public var scrollY:Int = 0;
	public var wrapX:Bool = false;
	public var wrapY:Bool = false;

	inline function checkBounds(x:Int, y:Int):Bool {
		return x >= 0 && y >= 0 && x < width && y < height;
	}

	/**
		Unnecessary wrapper to fill with the default color index 1
	 */
	public function clear(index:Int = 1)
		return fill(index);

	/**
		Set color index at given frame buffer position

		@param x X coordinate
		@param y Y coordinate
		@param index color index
	 */
	override public function set(x:Int, y:Int, index:Int) {
		if (index == 0)
			return;

		x += scrollX;
		y += scrollY;

		if (wrapX)
			x = wrap(x, width);

		if (wrapY)
			y = wrap(y, height);

		if (checkBounds(x, y))
			super.set(x, y, index);
	}
}
