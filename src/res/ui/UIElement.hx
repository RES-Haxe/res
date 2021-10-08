package res.ui;

import res.display.Renderable;

class UIElement extends Renderable {
	public var x:Float = 0;
	public var y:Float = 0;

	var children:Array<UIElement> = [];

	function renderElement(frameBuffer:IFrameBuffer, atx:Float, aty:Float) {
		for (child in children) {}
	}

	override function render(frameBuffer:IFrameBuffer) {}
}
