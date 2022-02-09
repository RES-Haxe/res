package res.tools;

class MathTools {
	public static inline function clampi(x:Int, low:Int, high:Int):Int
		return x <= low ? low : x >= high ? high : x;

	public static inline function clampf(x:Float, low:Float, high:Float):Float
		return x <= low ? low : x >= high ? high : x;

	/**
		Linear interpolation function

		@param a
		@param b
		@param t
	 */
	public static inline function lerp(a:Float, b:Float, t:Float):Float
		return a + (b - a) * t;

	public static inline function param(a:Float, b:Float, v:Float):Float
		return (v - a) / (b - a);

	public static inline function maxi(a:Int, b:Int):Int
		return a > b ? a : b;

	public static inline function mini(a:Int, b:Int):Int
		return a < b ? a : b;

	public static inline function wrapf(x:Float, w:Float):Float {
		if (x < 0)
			x = w + (x % w);

		if (x >= w)
			x = x % w;

		return x;
	}

	public static inline function wrapi(x:Int, w:Int):Int {
		if (x < 0)
			x = w + (x % w);

		if (x >= w)
			x = x % w;

		return x;
	}

	public static inline function sign(x:Float):Int {
		return x == 0 ? 0 : x < 0 ? -1 : 1;
	}
}
