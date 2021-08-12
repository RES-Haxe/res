package res;

import res.display.Renderable;
import res.input.ControllerButton;
import res.input.ControllerEvent;
import res.input.KeyboardEvent;
import res.input.MouseEvent;

using Std;

class Scene extends Renderable implements Updateable {
	@:allow(res)
	final res:RES;

	final renderList:Array<Renderable> = [];
	final updateList:Array<Updateable> = [];

	var clearColorIndex:Null<Int>;

	public function new(res:RES) {
		this.res = res;

		clearColorIndex = res.palette.darkestIndex;
	}

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
			frameBuffer.fill(clearColorIndex);

		for (renderable in renderList)
			if (renderable.visible)
				renderable.render(frameBuffer);
	}
}
