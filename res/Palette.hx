package res;

class Palette {
	var _colors:Array<Color>;

	public var colors(get, never):Array<Color>;

	function get_colors():Array<Color> {
		return _colors;
	}

	public var indecies(get, never):Array<Int>;

	function get_indecies():Array<Int> {
		return [for (n in 0..._colors.length) n + 1];
	};

	public inline function rnd():Color {
		return _colors[Math.floor(Math.random() * _colors.length)];
	}

	/**
		1-based color index (0 = transparency)
	 */
	public inline function get(index:Int):Color {
		return _colors[index - 1];
	}

	public function new(rgbColors:Array<Int>) {
		this._colors = rgbColors.map(col -> Color.fromInt24(col));
	}
}
