package res;

import haxe.io.Bytes;

class Bitmap {
	public final width:Int;
	public final height:Int;

	public final data:Bytes;

	public function new(width:Int, height:Int) {
		this.width = width;
		this.height = height;

		data = Bytes.alloc(width * height);
	}

	public inline function isInBounds(x:Int, y:Int):Bool {
		return x >= 0 && y >= 0 && x < width && y < height;
	}

	public dynamic function round(x:Float) {
		return Std.int(x);
	}

	/**
		Copy pixels from a source Bitmap
	 */
	public function copy(src:Bitmap, dstX:Int = 0, dstY:Int = 0, transparency:Bool = true) {
		if (dstX >= width)
			return;
		if (dstY >= height)
			return;
		if (dstX + src.width < 0)
			return;
		if (dstY + src.height < 0)
			return;

		for (line in 0...src.height) {
			if (dstY + line >= height)
				break;
			for (col in 0...src.width) {
				if (dstX + col >= width)
					break;

				seti(dstX + col, dstY + line, src.get(col, line), transparency);
			}
		}
	}

	/**
		Get color index at given position

		@param x X coordinate
		@param y Y coordinate
	 */
	public inline function get(x:Int, y:Int):Int {
		return data.get(y * width + x);
	}

	/**
		Set color index at given frame buffer position

		@param x X coordinate (integer)
		@param y Y coordinate (integer)
		@param index color index
		@param transparency whether transparency index should be skipped or set
	 */
	public function seti(x:Int, y:Int, index:Int, transparency:Bool = true) {
		if (!isInBounds(x, y))
			return;

		if (transparency && index == 0)
			return;

		data.set(y * width + x, index);
	}

	/**
		Set color index at given frame buffer position

		@param x X coordinate
		@param y Y coordinate
		@param index color index
		@param transparency whether transparency index should be skipped or set
	 */
	inline public function set(x:Float, y:Float, index:Int, transparency:Bool = true) {
		seti(round(x), round(y), index, transparency);
	}

	/**
		Fill the bitmap with a color
	 */
	public function fill(index:Int) {
		data.fill(0, data.length, index);
		return this;
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

			seti(x + col, y + line, index);

			col++;

			if (col == lineWidth) {
				col = 0;
				line++;
			}

			pos++;
		}

		return this;
	}
}
