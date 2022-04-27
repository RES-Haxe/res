package res.audio.osc;

import res.tools.MathTools.clamp;
import res.tools.MathTools.wrap;

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
		return frequency = clamp(val, 0, 20000);
	}

	var _period:Float = 0;

	public var period(get, never):Float;

	inline function get_period()
		return _period;

	public var period_length(get, never):Float;

	inline function get_period_length()
		return 1000 / frequency;

	/**
		Advance time by amount of milliseconds

		@param ms the amount of milliseconds to advance
	 */
	public function advance(ms:Float):Float {
		totalTime += ms;

		_period = wrap(_period + ms / period_length, 1);

		return amplitude;
	}

	public function reset() {
		totalTime = 0;
	}
}
