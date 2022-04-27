package res.audio.osc;

class Noise extends Oscillator {
	static inline function rndAmp()
		return -1 + Math.random() * 2;

	var currentAmp:Float = rndAmp();

	override function get_amplitude():Float
		return currentAmp;

	override function advance(ms:Float):Float {
		if (period + ms / period_length > 1)
			currentAmp = rndAmp();

		return super.advance(ms);
	}

	@:allow(res.audio.osc)
	private function new() {}
}
