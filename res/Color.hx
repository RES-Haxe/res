package res;

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

	public inline function format(pixelFormat:PixelFormat):Color {
		switch (pixelFormat) {
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

	public function new(rgba:Int = 0) {
		this = rgba;
	}
}
