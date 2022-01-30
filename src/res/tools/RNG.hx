package res.tools;

/**
	Random Number Generator
 */
class RNG {
	/**
		Returns a value based on chance

		@param prob Probability for 0 (will not happen) to 1 (will definetely happen)
		@param success Value to return if probability played out
		@param fail Value to return otherwise
	 */
	public static function chance<T>(prob:Float, success:T, fail:T) {
		if (rnd() <= prob)
			return success;
		else
			return fail;
	}

	/**
		Returns a random element from an Array
	 */
	public static function oneof<T>(arr:Array<T>):T
		return arr[Math.floor(rnd() * arr.length)];

	/**
		Pseudo-random number generator. 

		By default uses `Math.random()` function
		but can be redefined as it is a dynamic function

		@returns number `>=0.0` and `<1.0`
	 */
	public dynamic static function rnd()
		return Math.random();

	/**
		Returns a random `Float` number between `from` and `to`
	 */
	public static function rangef(from:Float, to:Float):Float
		return MathTools.lerp(from, to, rnd());

	/**
		Returns a random `Int` number between `from` and `to`
	 */
	public static function rangei(from:Int, to:Int):Int
		return Math.floor(rangef(from, to));
}
