package res;

import res.audio.AudioMixer;
import res.display.FrameBuffer;
import res.input.ControllerEvent;
import res.input.KeyboardEvent;
import res.input.MouseEvent;

using Std;

class State {
	public var audioMixer:AudioMixer;

	/** Color index to use to clear the screen (darkest color index by default) **/
	public var clearColorIndex:Null<Int> = null;

	public var res(default, set):RES;

	function set_res(_res:RES) {
		if (res == null) {
			res = _res;

			audioMixer = res.bios.createAudioMixer();
			audioMixer.audioBufferCache = res.audioBufferCache;

			clearColorIndex = res.rom.palette.darkest;
		}

		return res;
	}

	/** A list of things to render. A "thing" must have a `render` method that accepts `FrameBuffer` as the only argument **/
	final renderList:Array<{function render(fb:FrameBuffer):Void;}> = [];

	/** A list of things to update. A "thing" must have a `update` method that accepts a `Float` as the only argument (for time delta) **/
	final updateList:Array<{function update(dt:Float):Void;}> = [];

	public function new() {}

	/**
		Add to updateList or renderList or both depending on the type of the parameter
	 */
	public function add(?both:{function update(dt:Float):Void; function render(fb:FrameBuffer):Void;}, ?update:{function update(dt:Float):Void;},
			?render:{function render(fb:FrameBuffer):Void;}) {
		if (both != null) {
			updateList.push(both);
			renderList.push(both);
		} else if (update != null)
			updateList.push(update);
		else if (render != null)
			renderList.push(render);
	}

	public function remove(?both:{function update(dt:Float):Void; function render(fb:FrameBuffer):Void;}, ?update:{function update(dt:Float):Void;},
			?render:{function render(fb:FrameBuffer):Void;}) {
		if (both != null) {
			updateList.remove(both);
			renderList.remove(both);
		} else if (update != null)
			updateList.remove(update);
		else if (render != null)
			renderList.remove(render);
	}

	public dynamic function enter() {}

	public dynamic function init() {}

	public dynamic function leave() {}

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

		for (item in renderList)
			item.render(fb);
	}
}
