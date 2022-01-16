package res;

import res.audio.AudioMixer;
import res.display.FrameBuffer;
import res.input.ControllerEvent;
import res.input.KeyboardEvent;
import res.input.MouseEvent;

using Std;

class Scene {
	@:allow(res)
	var res(default, set):RES;

	function set_res(_res:RES) {
		res = _res;

		audioMixer = res.bios.createAudioMixer();
		audioMixer.audioBufferCache = res.audioBufferCache;

		clearColorIndex = res.rom.palette.darkestIndex;

		return res;
	}

	final renderList:Array<{function render(fb:FrameBuffer):Void;}> = [];
	final updateList:Array<{function update(dt:Float):Void;}> = [];

	@:allow(res)
	var audioMixer:AudioMixer;

	/**
		Color index to use to clear the screen (brightest color index by default)
	 */
	public var clearColorIndex:Null<Int> = null;

	public function new() {}

	public function enter() {}

	public function init() {}

	public function leave() {}

	public dynamic function controllerEvent(event:ControllerEvent) {}

	public dynamic function keyboardEvent(event:KeyboardEvent) {}

	public dynamic function mouseEvent(event:MouseEvent) {}

	public function update(dt:Float) {
		for (item in updateList)
			item.update(dt);
	}

	public function render(fb:FrameBuffer) {
		if (clearColorIndex != null)
			fb.clear(clearColorIndex);

		for (renderable in renderList)
			renderable.render(fb);
	}
}
