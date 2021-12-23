package res.platforms.heaps;

import h2d.Interactive;
import hxd.Pad;
import res.audio.IAudioBuffer;
import res.audio.IAudioMixer;
import res.audio.IAudioStream;
import res.display.FrameBuffer;
import res.storage.IStorage;

using Math;
using res.tools.ResolutionTools;

class HeapsPlatform implements IPlatform {
	public final name:String = 'Heaps';

	var screen:h2d.Bitmap;
	var s2d:h2d.Scene;

	public function new(s2d:h2d.Scene) {
		this.s2d = s2d;
		screen = new h2d.Bitmap(s2d);

		Pad.wait(onPad);
	}

	function onPad(pad:Pad) {}

	/**
		Connect input
	 */
	public function connect(res:RES) {
		final frameSize = res.config.resolution.pixelSize();

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

	public function createAudioBuffer(audioStream:IAudioStream):IAudioBuffer {
		return new AudioBuffer(audioStream);
	}

	public function createAudioMixer():IAudioMixer {
		return new AudioMixer();
	}

	public function createFrameBuffer(width:Int, height:Int, palette:Palette):FrameBuffer {
		return new res.platforms.heaps.FrameBuffer(s2d, width, height, palette);
	}

	public function createStorage():IStorage {
		#if js
		return new res.platforms.js.Html5Storage();
		#else
		return new res.platforms.common.FileStorage();
		#end
	}
}
