package res.audio.osc;

class Sawtooth extends Oscillator {
	override function get_amplitude():Float
		return -1 + 2 * period;

	@:allow(res.audio.osc)
	private function new() {}
}
