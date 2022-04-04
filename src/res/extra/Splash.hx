package res.extra;

import Math.*;
import res.display.FrameBuffer;
import res.text.Font;
import res.timeline.Timeline;
import res.tools.MathTools.wrap;

using res.display.Painter;
using res.display.Sprite;

class Splash extends State {
	static final TIME:Int = 1;
	static final BAR_SIZE:Int = 8;

	final stateFn:Void->State;

	var font:Font;

	var scroll:Float = 0;

	public function new(stateFn:Void->State) {
		super();

		this.stateFn = stateFn;
	}

	override public function init() {
		var timeline = new Timeline();

		timeline.after(TIME, (_) -> {
			final state = stateFn();
			if (state != null)
				res.setState(state, true);
		});

		updateList.push(timeline);

		font = res.rom.fonts['num'];

		if (font == null)
			font = res.defaultFont;
	}

	override function update(dt:Float) {
		scroll = wrap(scroll + 20 * dt, res.rom.palette.colors.length - 2);
	}

	override function render(frameBuffer:FrameBuffer) {
		frameBuffer.clear(clearColorIndex);

		for (line in 0...frameBuffer.height) {
			final numLine = 1 + wrap(floor(line / BAR_SIZE), res.rom.palette.colors.length - 2);

			for (col in 0...frameBuffer.width) {
				if ((line < 8 || line >= frameBuffer.height - 8) || (col < 8 || col >= frameBuffer.width - 8)) {
					final numCol = 1 + wrap(floor(col / BAR_SIZE), res.rom.palette.colors.length - 2);
					frameBuffer.set(col, line, 1 + wrap(numLine + numCol - floor(scroll), res.rom.palette.colors.length - 2));
				}
			}
		}

		final sp = res.rom.sprites['splash'];

		frameBuffer.drawSprite(sp, Std.int((frameBuffer.width - sp.width) / 2), Std.int((frameBuffer.height - sp.height) / 2));

		if (font != null)
			font.drawPivot(frameBuffer, 'v${RES.VERSION}', Std.int(frameBuffer.width / 2), Std.int(frameBuffer.height / 2 + sp.height / 2) + 2, 0.5, 0);
	}
}
