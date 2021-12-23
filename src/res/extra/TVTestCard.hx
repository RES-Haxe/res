package res.extra;

using res.graphics.Painter;

class TVTestCard extends Scene {
	final indecies:Array<Int>;

	public function new(res:RES) {
		super(res);

		indecies = res.rom.palette.byLuminance.copy();
		indecies.reverse();
	}

	override function render(frameBuffer:FrameBuffer) {
		frameBuffer.clear(0);

		final barw = Math.floor(frameBuffer.frameWidth / 8);

		for (bar in 0...8) {
			frameBuffer.rect(bar * barw, 0, barw, frameBuffer.frameHeight, indecies[bar]);
		}
	}
}
