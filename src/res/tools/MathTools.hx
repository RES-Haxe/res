package res.tools;

class MathTools {
	public static inline function clampi(x:Int, low:Int, high:Int):Int
		return x <= low ? low : x >= high ? high : x;

	public static inline function maxi(a:Int, b:Int):Int
		return a > b ? a : b;

	public static inline function mini(a:Int, b:Int):Int
		return a < b ? a : b;

	public static inline function wrapi(x:Int, w:Int):Int {
		if (x < 0)
			x = w + (x % w);

		if (x >= w)
			x = x % w;

		return x;
	}
}
