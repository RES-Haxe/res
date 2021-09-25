package res;

using StringTools;

/**
	RGBA color
 */
abstract Color(Int) from Int to Int from UInt to UInt {
	public var r(get, never):Int;

	inline function get_r() {
		return (this >> 24) & 0xFF;
	}

	public var g(get, never):Int;

	inline function get_g() {
		return (this >> 16) & 0xFF;
	}

	public var b(get, never):Int;

	inline function get_b():Int {
		return (this >> 8) & 0xFF;
	}

	public var a(get, never):Int;

	inline function get_a():Int {
		return this & 0xFF;
	}

	public var rf(get, never):Float;

	inline function get_rf()
		return r / 255;

	public var gf(get, never):Float;

	inline function get_gf()
		return g / 255;

	public var bf(get, never):Float;

	inline function get_bf()
		return b / 255;

	public var af(get, never):Float;

	inline function get_af()
		return a / 255;

	public var luminance(get, never):Float;

	/**
		`L = 0.2126 * R + 0.7152 * G + 0.0722 * B` where R, G and B are defined as:

		```
		if RsRGB <= 0.03928 then R = RsRGB/12.92 else R = ((RsRGB+0.055)/1.055) ^ 2.4
		if GsRGB <= 0.03928 then G = GsRGB/12.92 else G = ((GsRGB+0.055)/1.055) ^ 2.4
		if BsRGB <= 0.03928 then B = BsRGB/12.92 else B = ((BsRGB+0.055)/1.055) ^ 2.4
		```

		and RsRGB, GsRGB, and BsRGB are defined as:

		```
		RsRGB = R8bit/255
		GsRGB = G8bit/255
		BsRGB = B8bit/255
		```

		@see https://www.w3.org/WAI/GL/wiki/Relative_luminance
	 */
	function get_luminance():Float {
		final lr:Float = rf <= 0.3928 ? rf / 12.92 : Math.pow((rf + 0.055) / 1.055, 2.4);
		final lg:Float = gf <= 0.3928 ? gf / 12.92 : Math.pow((gf + 0.055) / 1.055, 2.4);
		final lb:Float = bf <= 0.3928 ? bf / 12.92 : Math.pow((bf + 0.055) / 1.055, 2.4);

		return 0.2126 * lr + 0.7152 * lg + 0.0722 * lb;
	}

	/**
		Calculate distance to the given color

		@param otherColor Color to compare to
	 */
	public function distance(otherColor:Color):Float {
		return Math.pow(r - otherColor.r, 2) + Math.pow(g - otherColor.g, 2) + Math.pow(b - otherColor.b, 2);
	}

	public inline function format(pixelFormat:PixelFormat):Color {
		switch (pixelFormat) {
			case BGRA:
				return fromARGB(b, g, r, a);
			case ABGR:
				return fromARGB(a, b, g, r);
			case ARGB:
				return fromARGB(a, r, g, b);
			case RGB:
				return (((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF));
			case RGBA:
				return this;
		}
	}

	public static inline function fromInt24(int:Int, alpha:Int = 255):Color {
		var col:Color = int << 8;
		col.setRGBA(col.r, col.g, col.b, alpha);
		return col;
	}

	public static inline function fromARGB(?a:Int = 1, r:Int, g:Int, b:Int):Color {
		return ((a & 0xFF) << 24) | ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF);
	}

	public static inline function fromRGBA(r:Int, g:Int, b:Int, a:Int = 255):Color {
		return ((r & 0xFF) << 24) | ((g & 0xFF) << 16) | ((b & 0xFF) << 8) | (a & 0xFF);
	}

	public inline function setRGBA(r:Int, g:Int, b:Int, a:Int = 255) {
		this = fromRGBA(r, g, b, a);
	}

	public function toString():String
		return this.hex(8) + ' r=${r.hex(2)},g=${g.hex(2)},b=${b.hex(2)},a=${a.hex(2)}';

	public function new(rgba:Int = 0) {
		this = rgba;
	}
}
