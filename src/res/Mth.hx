package res;

class Mth {
	/**
		Calculate average
	**/
	public static function avg(numbers:Array<Float>):Float {
		return sum(numbers) / numbers.length;
	}

	/**
		Bezier curve

		@param points Control points
		@param t Parameter
	 */
	public static function bezier(points:Array<{x:Float, y:Float}>, t:Float):{x:Float, y:Float} {
		if (points.length == 2) {
			return {
				x: lerp(points[0].x, points[1].x, t),
				y: lerp(points[0].y, points[1].y, t)
			};
		} else if (points.length > 2) {
			return bezier([for (n in 0...points.length - 1)
				{
					x: lerp(points[n].x, points[n + 1].x, t),
					y: lerp(points[n].y, points[n + 1].y, t)
				}], t);
		} else
			throw 'Too few control points';
	}

	/**
		Clamps a value between an upper and lower bound
	 */
	public static inline function clamp<T:Float>(x:T, low:T, high:T):T
		return x <= low ? low : x >= high ? high : x;

	/**
		Linear interpolation

		@param a From value
		@param b To value
		@param t Parameter
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

		```haxe
		return (v - a) / (b - a);
		```

		If `a` equals `0`, `b` equals `100` and `v` equals to `50` - returns `0.5`

		@param a From value (0)
		@param b To value (1)
		@param v The value
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
	public static function sum(nums:Array<Float>):Float {
		var result:Float = 0;

		for (n in nums)
			result += n;

		return result;
	}

	/**
		"Wrap around" a number.

		- If `x >= w` - returns `x % w`
		- If `x < 0` - returns `w + (x % w)`

		Useful to make sure a number is always within `0, w` boundaries for repeating patterns

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
