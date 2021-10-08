package res.platforms.heaps;

import res.types.RESConfig;
import h2d.Interactive;
import hxd.Pad;

using Math;
using res.tools.ResolutionTools;

class HeapsPlatform extends Platform {
	var screen:h2d.Bitmap;
	var s2d:h2d.Scene;

	var _frameBuffer:FrameBuffer;

	override function get_name():String {
		return 'Heaps';
	}

	override function get_frameBuffer():IFrameBuffer {
		return _frameBuffer;
	}

	public function new(s2d:h2d.Scene) {
		this.s2d = s2d;
		screen = new h2d.Bitmap(s2d);

		Pad.wait(onPad);
	}

	function onPad(pad:Pad) {}

	/**
		Connect input
	 */
	override public function connect(res:RES) {
		final frameSize = res.config.resolution.pixelSize();

		_frameBuffer = new FrameBuffer(s2d, frameSize.width, frameSize.height, res.rom.palette);

		s2d.scaleMode = LetterBox(frameSize.width, frameSize.height);

		final interactive = new Interactive(frameSize.width, frameSize.height, s2d);

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
}
