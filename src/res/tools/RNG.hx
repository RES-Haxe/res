package res.tools;

/**
	Random Number Generator
 */
class RNG {
	/**
		Returns a random element from an Array
	 */
	public static function oneof<T>(arr:Array<T>):T
		return arr[Math.floor(Math.random() * arr.length)];

	/**
		Returns a random `Float` number between `from` and `to`
	 */
	public static function rangef(from:Float, to:Float):Float
		return MathTools.lerp(from, to, Math.random());

	/**
		Returns a random `Int` number between `from` and `to`
	 */
	public static function rangei(from:Int, to:Int):Int
		return Math.floor(rangef(from, to));
}
