package res.platforms.heaps;

import h2d.Interactive;
import hxd.Pad;

using Math;

class HeapsPlatform extends Platform {
	var screen:h2d.Bitmap;
	var s2d:h2d.Scene;

	public function new(s2d:h2d.Scene) {
		super('Heaps', ARGB);

		this.s2d = s2d;
		screen = new h2d.Bitmap(s2d);

		Pad.wait(onPad);
	}

	function onPad(pad:Pad) {}

	/**
		Connect input
	 */
	override public function connect(res:RES) {
		s2d.scaleMode = LetterBox(res.frameBuffer.frameWidth, res.frameBuffer.frameHeight);

		final interactive = new Interactive(res.frameBuffer.frameWidth, res.frameBuffer.frameHeight, s2d);

		interactive.onMove = (ev) -> {
			res.mouse.moveTo(ev.relX.floor(), ev.relY.floor());
		};

		interactive.onPush = (ev) -> {
			res.mouse.push(switch (ev.button) {
				case 0: LEFT;
				case 1: RIGHT;
				case 2: MIDDLE;
				case _: LEFT;
			}, ev.relX.floor(), ev.relY.floor());
		};

		interactive.onRelease = interactive.onReleaseOutside = (ev) -> {
			res.mouse.release(switch (ev.button) {
				case 0: LEFT;
				case 1: RIGHT;
				case 2: MIDDLE;
				case _: LEFT;
			}, ev.relX.floor(), ev.relY.floor());
		};

		hxd.Window.getInstance().addEventTarget((ev) -> {
			switch (ev.kind) {
				case EKeyDown:
					res.keyboard.keyDown(ev.keyCode);
				case ETextInput:
					res.keyboard.keyPress(ev.charCode);
				case EKeyUp:
					res.keyboard.keyUp(ev.keyCode);
				case _:
			}
		});
	}

	override public function render(res:RES) {
		screen.tile = h2d.Tile.fromPixels(new hxd.Pixels(res.frameBuffer.frameWidth, res.frameBuffer.frameHeight, res.frameBuffer.getFrame(), RGBA));
	}
}
