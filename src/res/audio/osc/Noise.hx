package res.audio.osc;

class Noise extends Oscillator {
	var numFrame:Int = 0;
	var currentAmp:Float = -1 + Math.random() * 2;

	override function get_amplitude():Float {
		return currentAmp;
	}

	override function advance(ms:Float):Float {
		totalTime += ms;

		final frame:Int = Std.int(totalTime / ((1000 / frequency) / 2));

		if (frame != numFrame) {
			currentAmp = -1 + Math.random() * 2;
			numFrame = frame;
		}

		return amplitude;
	}

	override function reset() {
		super.reset();
		numFrame = 0;
	}

	@:allow(res.audio.osc)
	private function new() {}
}
