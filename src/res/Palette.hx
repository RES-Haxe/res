package res;

import res.types.ColorComponent;

class Palette {
	public final colors:Array<Color32>;

	final _indecies:Array<Int>;

	/**
		Maps colors to their indecies
	 */
	final _indexMap:Map<Int, Int>;

	/**
		Array of all color indexes of the palette
	 */
	public var indecies(get, never):Array<Int>;

	inline function get_indecies()
		return _indecies;

	final _luminance:Array<Int>;

	/**
		Color **indecies** sorted by their luminance from darkest to brightest
	 */
	public var luminance(get, never):Array<Int>;

	inline function get_luminance()
		return _luminance;

	/**
		Index of the brightest color in the palette
	 */
	public var brightest(get, never):Int;

	inline function get_brightest():Int
		return _luminance[_luminance.length - 1];

	/**
		Index of the darkest color in the palette
	 */
	public var darkest(get, never):Int;

	inline function get_darkest():Int
		return _luminance[0];

	/**
		Number of colors in the Palette
	 */
	public var numColors(get, never):Int;

	inline function get_numColors():Int
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
		var distances:Array<{index:Int, distance:Float}> = [for (i in indecies)
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
	public function createIndecies():Array<Int>
		return indecies.slice(0);

	/**
		Get color by its index 

		@param index 1-based color index
	 */
	public inline function get(index:Int):Color32
		return colors[index - 1];

	/**
		Get the index of a given Color32

		This function will only use RGB components of
		the color to match the existing color independently
		of how the color actually stored in memory

		@param color
			   Color to find index for
		@param useClosest
			   if `true` will use `closest()` function
				to find the index of the closest color in the palette
	 */
	public inline function getIndex(color:Color32, ?useClosest:Bool = false):Int {
		if (!_indexMap.exists(color.hash))
			return useClosest ? closest(color) : 0;
		return _indexMap[color.hash];
	}

	/**
		Create a palette with default colors
	 */
	public static function createDefault():Palette {
		// SWEETIE 16 PALETTE: https://lospec.com/palette-list/sweetie-16
		return Palette.rgb8([
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

		_indexMap = [];

		for (idx in 0...colors.length) {
			_indexMap[colors[idx].hash] = idx + 1;
		}

		_indecies = [for (i in 1...numColors + 1) i];

		_luminance = createIndecies();
		_luminance.sort((idxa, idxb) -> {
			if (get(idxa).luminance == get(idxb).luminance)
				return 0;
			if (get(idxa).luminance > get(idxb).luminance)
				return 1;
			else
				return -1;
		});
	}
}
