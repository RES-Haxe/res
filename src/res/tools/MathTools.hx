package res.tools;

class MathTools {
	/**
		Clamps a value between an upper and lower bound
	 */
	public static inline function clamp<T:Float>(x:T, low:T, high:T):T
		return x <= low ? low : x >= high ? high : x;

	/**
		Linear interpolation

		@param a
		@param b
		@param t
	 */
	public static inline function lerp(a:Float, b:Float, t:Float):Float
		return a + (b - a) * t;

	/**
		Type aware `max` function
	 */
	public static inline function max<T:Float>(a:T, b:T):T
		return a > b ? a : b;

	/**
		Type aware `min` function
	 */
	public static inline function min<T:Float>(a:T, b:T):T
		return a < b ? a : b;

	/**
		Returns parameter useful for `lerp` function
	 */
	public static inline function param(a:Float, b:Float, v:Float):Float
		return (v - a) / (b - a);

	/**
		Returns l
		- `-1` if the number is negative
		- `+1` if the number is positive
		- `0` otherwise (the number is `0`)
	 */
	public static inline function sign(x:Float):Int
		return x == 0 ? 0 : x < 0 ? -1 : 1;

	/**
		Sum multiple numbers
	 */
	public static function sum(...nums:Float):Float {
		var result:Float = 0;

		for (n in nums)
			result += n;

		return result;
	}

	/**
		"Wrap around" a number.

		- If `x >= w` - returns `x % w`
		- If `x < 0` - returns `w + (x % w)`

		Useful to make sure a number is always within `0, w` boundaries

		@param x The number
		@param w The "width" of the boundaries 
	 */
	public static inline function wrap<T:Float>(x:T, w:T):T {
		if (x < 0)
			x = w + (x % w);

		if (x >= w)
			x = x % w;

		return x;
	}
}
