package res;

import res.Mth.wrap;

class FrameBuffer extends Bitmap {
	public var scrollX:Int = 0;
	public var scrollY:Int = 0;
	public var wrapX:Bool = false;
	public var wrapY:Bool = false;
	public var mask:Bitmap = null;

	/**
		Unnecessary wrapper to fill with the default color index 1
	 */
	inline public function clear(index:Int = 1) {
		return fill(index);
	}

	/**
		Set color index at given frame buffer position

		@param x X coordinate
		@param y Y coordinate
		@param index color index
	 */
	override public function seti(x:Int, y:Int, index:Int, transparency:Bool = true) {
		if (transparency && index == 0)
			return this;

		x += scrollX;
		y += scrollY;

		if (wrapX)
			x = wrap(x, width);

		if (wrapY)
			y = wrap(y, height);

		if (!isInBounds(x, y))
			return this;

		if (mask != null && x < mask.width && y < mask.height) {
			if (mask.get(x, y) == 0)
				return this;
		}

		super.seti(x, y, index, transparency);

		return this;
	}
}
