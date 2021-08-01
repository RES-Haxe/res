package res;

import res.geom.Point2i;
import res.input.Controller;
import res.input.ControllerButton;
import res.input.ControllerEvent;
import res.input.MouseEvent;
import res.timeline.Timeline;
import res.tween.Tweening;

using Std;

class Scene extends Renderable implements Updateable {
	@:allow(res)
	final res:RES;

	final renderList:Array<Renderable> = [];
	final updateList:Array<Updateable> = [];

	var clearColorIndex:Null<Int>;

	public final timeline:Timeline = new Timeline();
	public final tweening:Tweening = new Tweening();

	public function new(res:RES) {
		this.res = res;

		clearColorIndex = res.palette.darkestIndex;
	}

	/**
		Get controller direction of the default player
	 */
	public inline function dir(?playerNum:Int = 1):Point2i {
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

	public function keyDown(keyCode:Int) {}

	public function keyPress(charCode:Int) {}

	public function keyUp(keyCode:Int) {}

	public dynamic function controllerEvent(event:ControllerEvent) {}

	public dynamic function mouseEvent(event:MouseEvent) {}

	public function update(dt:Float) {
		timeline.update(dt);
		tweening.update(dt);

		for (item in updateList)
			item.update(dt);
	}

	override public function render(frameBuffer:FrameBuffer) {
		frameBuffer.fill(clearColorIndex);

		for (renderable in renderList)
			if (renderable.visible)
				renderable.render(frameBuffer);
	}
}
