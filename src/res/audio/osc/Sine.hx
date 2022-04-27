package res.audio.osc;

class Sine extends Oscillator {
	override function get_amplitude():Float
		return Math.sin(Math.PI * 2 * period);

	@:allow(res.audio.osc)
	private function new() {}
}
