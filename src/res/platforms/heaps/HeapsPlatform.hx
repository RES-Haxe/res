#if heaps
package res.platforms.heaps;

import hxd.Pad;

class HeapsPlatform implements Platform {
	var screen:h2d.Bitmap;

	public function new(?s2d:h2d.Scene) {
		screen = new h2d.Bitmap(s2d);

		Pad.wait(onPad);
	}

	function onPad(pad:Pad) {}

	/**
		Connect input
	 */
	public function connect(res:Res) {
		hxd.Window.getInstance().addEventTarget((ev) -> {
			switch (ev.kind) {
				case EMove:
					res.mouse.moveTo(Std.int(ev.relX / 4), Std.int(ev.relY / 4));
				case EPush:
					res.mouse.moveTo(Std.int(ev.relX / 4), Std.int(ev.relY / 4));
					res.mouse.push(switch (ev.button) {
						case 0: LEFT;
						case 1: RIGHT;
						case 2: MIDDLE;
						case _: LEFT;
					});
				case ERelease:
					res.mouse.moveTo(Std.int(ev.relX / 4), Std.int(ev.relY / 4));
					res.mouse.release(switch (ev.button) {
						case 0: LEFT;
						case 1: RIGHT;
						case 2: MIDDLE;
						case _: LEFT;
					});
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

	public function render(res:Res) {
		screen.tile = h2d.Tile.fromPixels(new hxd.Pixels(res.frameBuffer.frameWidth, res.frameBuffer.frameHeight, res.frameBuffer.getFrame(), RGBA));
	}
}
#end
