package res;

import res.types.ColorComponent;

class Palette {
	public final colors:Array<Color32>;

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
		return colors.length;

	/**
		Changes the output format for all the color in place

		@param outFormat output format for all colors

		@returns this palette
	 */
	public function format(outFormat:Array<ColorComponent>):Palette {
		for (color in colors)
			color.setOutFormat(outFormat);

		return this;
	}

	/**
		Returns the index of the closest color to the given

		@see https://en.wikipedia.org/wiki/Color_difference

		@param color Color to find the closes color to
		@returns the index of the closes color in the palette
	 */
	public function closest(color:Color32):Int {
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
		return [for (n in 0...colors.length) n];
	};

	/**
		Get color by its index 
	 */
	public function get(index:Int):Color32 {
		return colors[index];
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

	/**
		Create a palette with default colors
	 */
	public static function createDefault():Palette {
		// SWEETIE 16 PALETTE: https://lospec.com/palette-list/sweetie-16
		return Palette.rgb8([
			0x000000,
			0x1a1c2c,
			0x5d275d,
			0xb13e53,
			0xef7d57,
			0xffcd75,
			0xa7f070,
			0x38b764,
			0x257179,
			0x29366f,
			0x3b5dc9,
			0x41a6f6,
			0x73eff7,
			0xf4f4f4,
			0x94b0c2,
			0x566c86,
			0x333c57
		]);
	}

	/**
		Create a palette from a list of RGB8 colors.

		Mind that color #0 will always be used for trasparency

		@param colors Array of 24bit RGB colors
	 */
	public static function rgb8(colors:Array<Int>) {
		return new Palette(colors.map(c -> Color32.ofRGB8(c)));
	}

	@:allow(res)
	private function new(colors:Array<Color32>) {
		this.colors = colors;

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
