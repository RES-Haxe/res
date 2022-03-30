package res.extra;

import res.display.FrameBuffer;
import res.text.Font;
import res.timeline.Timeline;

using res.display.Sprite;

class Splash extends Scene {
	final scene:Void->Scene;

	var font:Font;

	public function new(scene:Void->Scene) {
		super();

		this.scene = scene;
	}

	override public function init() {
		var timeline = new Timeline();

		timeline.after(1, (_) -> {
			if (scene != null)
				res.setScene(scene(), true);
		});

		updateList.push(timeline);

		font = res.rom.fonts['num'];

		if (font == null)
			font = res.defaultFont;
	}

	override function render(frameBuffer:FrameBuffer) {
		frameBuffer.clear(clearColorIndex);

		final sp = res.rom.sprites['splash'];

		frameBuffer.drawSprite(sp, Std.int((frameBuffer.width - sp.width) / 2), Std.int((frameBuffer.height - sp.height) / 2));

		if (font != null)
			font.drawPivot(frameBuffer, 'v${RES.VERSION}', Std.int(frameBuffer.width / 2), Std.int(frameBuffer.height / 2 + sp.height / 2) + 2, 0.5, 0);
	}
}
