package res;

class Palette {
	var _colors:Array<Color>;

	/**
		Array of colors
	 */
	public var colors(get, never):Array<Color>;

	function get_colors():Array<Color> {
		return _colors;
	}

	var _byLuminance:Array<Int>;

	/**
		Color **indecies** sorted by their luminance
	 */
	public var byLuminance(get, never):Array<Int>;

	inline function get_byLuminance() {
		return _byLuminance;
	}

	/**
		Index of the brightest color in the palette
	 */
	public var brightestIndex(get, never):Int;

	inline function get_brightestIndex():Int
		return _byLuminance[_byLuminance.length - 1];

	/**
		Index of the darkest color in the palette
	 */
	public var darkestIndex(get, never):Int;

	inline function get_darkestIndex():Int
		return _byLuminance[1];

	public var size(get, never):Int;

	inline function get_size():Int
		return _colors.length;

	/**
		Returns the index of the closest color to the given

		@see https://en.wikipedia.org/wiki/Color_difference

		@param color Color to find the closes color to
		@returns the index of the closes color in the palette
	 */
	public function closest(color:Color):Int {
		var distances:Array<{index:Int, distance:Float}> = [for (i in 0...size)
			({
				index:i, distance:get(i).distance(color)
			})];

		distances.sort((a, b) -> a.distance == b.distance ? 0 : a.distance < b.distance ? -1 : 1);

		return distances[0].index;
	}

	/**
		Creates a new array containing all the color indecies.

		Suitable for creating index maps
	 */
	public function getIndecies():Array<Int> {
		return [for (n in 0..._colors.length) n];
	};

	/**
		Get random color index
	 */
	public inline function rnd():Int {
		return Math.floor(Math.random() * _colors.length);
	}

	/**
		Takes an array of colors

		@returns Array of indecies of the given colors
	 */
	public function sub(colors:Array<Int>):Array<Int> {
		return colors.map(col -> _colors.indexOf(col));
	}

	/**
		Get color by its index 
	 */
	public function get(index:Int):Color {
		return _colors[index];
	}

	/**
		Create a color ramp of colors ascending by their luminance

		@param numColor Number of colors in the ramp
		@param shift 

		@returns Array of color indecies. First index is the darkest in the ramp
	 */
	public function rampAsc(numColors:Int, shift:Int = 0):Array<Int> {
		return [0].concat(_byLuminance.slice(shift, shift + numColors));
	}

	/**
		Create a color ramp of colors descending by their luminance

		@param numColor Number of colors in the ramp
		@param shift 

		@returns Array of color indecies. First index is the brightest in the ramp
	 */
	public function rampDesc(numColors:Int, shift:Int = 0):Array<Int> {
		final rev = _byLuminance.copy();
		rev.reverse();
		return [0].concat(rev.slice(shift, shift + numColors));
	}

	@:allow(res)
	private function new(rgbColors:Array<Int>) {
		this._colors = rgbColors.map(col -> Color.fromInt24(col));

		_byLuminance = getIndecies();
		_byLuminance.sort((idxa, idxb) -> {
			if (get(idxa).luminance == get(idxb).luminance)
				return 0;
			if (get(idxa).luminance > get(idxb).luminance)
				return 1;
			else
				return -1;
		});
	}
}
