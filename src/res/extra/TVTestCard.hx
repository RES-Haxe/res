package res.extra;

import res.display.FrameBuffer;

using res.display.Painter;

class TVTestCard extends Scene {
	var indecies:Array<Int>;

	override public function init() {
		indecies = res.rom.palette.byLuminance.copy();
		indecies.reverse();
	}

	override function render(frameBuffer:FrameBuffer) {
		frameBuffer.clear(0);

		final barw = Math.floor(frameBuffer.frameWidth / 8);

		for (bar in 0...8) {
			frameBuffer.rect(bar * barw, 0, barw, frameBuffer.frameHeight, indecies[bar], indecies[bar]);
		}
	}
}
