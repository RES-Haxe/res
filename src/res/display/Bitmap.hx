package res.display;

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

		@param x X coordinate
		@param y Y coordinate
		@param index color index
	 */
	public function set(x:Int, y:Int, index:Int) {
		if (index == 0)
			return;
		data.set(y * width + x, index);
	}
}
