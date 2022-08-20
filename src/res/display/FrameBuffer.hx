package res.display;

import haxe.io.Bytes;
import res.tools.MathTools.wrap;

class FrameBuffer extends Bitmap {
	public var scrollX:Int = 0;
	public var scrollY:Int = 0;
	public var wrapX:Bool = false;
	public var wrapY:Bool = false;

	inline function checkBounds(x:Int, y:Int):Bool {
		return x >= 0 && y >= 0 && x < width && y < height;
	}

	public function clear(index:Int) {
		data.fill(0, data.length, index);
	}

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

	/**
		Output raster data line by line

		@param x Screen x coordinate
		@param y Screen y coordinate
		@param data Bytes with raster indecies
		@param srcPos Position of the first index in data
		@param lineWidth The width of each line in raster
		@param numLine Number of line to draw. If not specified - set all the indecies from the data
		@param colorMap Optional color map
	 */
	public function raster(x:Int, y:Int, data:Bytes, srcPos:Int, lineWidth:Int, ?numLines:Int, ?colorMap:IndexMap) {
		var pos = 0;
		var col = 0;
		var line = 0;

		while (srcPos + pos < data.length && (numLines == null || line < numLines)) {
			final idxPos = srcPos + pos;

			final dataIndex = data.get(idxPos);
			final index = colorMap == null ? dataIndex : colorMap[dataIndex];

			set(x + col, y + line, index);

			col++;

			if (col == lineWidth) {
				col = 0;
				line++;
			}

			pos++;
		}
	}
}
