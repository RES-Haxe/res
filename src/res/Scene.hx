package res;

import res.audio.IAudioMixer;
import res.display.FrameBuffer;
import res.display.Renderable;
import res.input.ControllerButton;
import res.input.ControllerEvent;
import res.input.KeyboardEvent;
import res.input.MouseEvent;

using Std;

class Scene extends Renderable implements Updateable {
	@:allow(res)
	var res(default, set):RES;

	function set_res(_res:RES) {
		res = _res;

		audioMixer = res.platform.createAudioMixer();

		clearColorIndex = res.rom.palette.darkestIndex;

		return res;
	}

	final renderList:Array<Renderable> = [];
	final updateList:Array<Updateable> = [];

	@:allow(res)
	var audioMixer:IAudioMixer;

	public var clearColorIndex:Null<Int> = null;

	public function new() {}

	public function enter() {}

	public function init() {}

	public function leave() {}

	/**
		Get controller direction of the default player
	 */
	public inline function dir(?playerNum:Int = 1) {
		return res.controllers[playerNum].direction;
	}

	/**
		Get controller button state of the default player
	 */
	public inline function btn(?playerNum:Int = 1, controllerButton:ControllerButton):Bool {
		return res.controllers[playerNum].isPressed(controllerButton);
	}

	/**
		Add renderable to scene
	 */
	public function add(?renderable:Renderable, ?updatable:Updateable) {
		if (renderable != null) {
			renderList.push(renderable);
			if (renderable.isOfType(Updateable))
				updateList.push(cast renderable);
		}

		if (updatable != null)
			updateList.push(updatable);
	}

	/**
		Remove renderable from scene
	 */
	public function remove(?renderable:Renderable, ?updatable:Updateable) {
		if (renderable != null) {
			renderList.remove(renderable);

			if (renderable.isOfType(Updateable)) {
				updateList.remove(cast renderable);
			}
		}

		if (updatable != null)
			updateList.remove(updatable);
	}

	public dynamic function controllerEvent(event:ControllerEvent) {}

	public dynamic function keyboardEvent(event:KeyboardEvent) {}

	public dynamic function mouseEvent(event:MouseEvent) {}

	public function update(dt:Float) {
		for (item in updateList)
			item.update(dt);
	}

	override public function render(frameBuffer:FrameBuffer) {
		if (clearColorIndex != null)
			frameBuffer.clear(clearColorIndex);

		for (renderable in renderList)
			if (renderable.visible)
				renderable.render(frameBuffer);
	}
}
