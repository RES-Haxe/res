package res.audio.osc;

class Triangle extends Oscillator {
	override function get_amplitude():Float
		return -1 + Math.abs((-1 + period * 2) % 2) * 2;

	@:allow(res.audio.osc)
	private function new() {}
}
