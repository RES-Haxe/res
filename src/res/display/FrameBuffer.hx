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

	/**
		Get color index at given position

		@param x X coordinate
		@param y Y coordinate
	 */
	public function get(x:Int, y:Int):Int {
		return _indecies.get(y * width + x);
	}

	/**
		Set color index at given frame buffer position

		@param x X coordinate
		@param y Y coordinate
		@param index color index
	 */
	public function set(x:Int, y:Int, index:Int) {
		if (index == 0)
			return;

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
	public function raster(x:Int, y:Int, data:Bytes, srcPos:Int, lineWidth:Int, ?numLines:Int, ?colorMap:ColorMap) {
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
