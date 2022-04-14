package res.audio.osc;

import res.tools.MathTools.clamp;

abstract class Oscillator {
	public static function noise()
		return new Noise();

	public static function sawtooth()
		return new Sawtooth();

	public static function sine()
		return new Sine();

	public static function square()
		return new Square();

	public static function triangle()
		return new Triangle();

	/** Total sfx time in milliseconds */
	var totalTime:Float = 0;

	public var amplitude(get, never):Float;

	function get_amplitude():Float
		return 0;

	public var frequency(default, set):Float;

	function set_frequency(val:Float) {
		return frequency = clamp(val, 20, 20000);
	}

	/**
		Advance time by amount of milliseconds

		@param ms the amount of milliseconds to advance
	 */
	public function advance(ms:Float):Float {
		totalTime += ms;
		return amplitude;
	}

	public inline function period():Float {
		final l = 1000 / frequency;
		return (totalTime % l) / l;
	}

	public function reset() {
		totalTime = 0;
	}
}
