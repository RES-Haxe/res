package res.display;

using Math;

class Object extends Renderable implements Updateable {
	public var x:Float;
	public var y:Float;

	public var width:Float;
	public var height:Float;

	public var colorMap:Array<Int> = null;

	var parent:Object;

	final children:Array<Object> = [];

	public function add(obj:Object) {
		obj.parent = this;
		children.push(obj);
	}

	public function remove(obj:Object) {
		children.remove(obj);
		obj.parent = null;
	}

	/**
		Render graphics for this object (or not)

		@param frameBuffer Frame buffer to render to
		@param atx Screen X position to render
		@param aty Screen Y position to render
	 */
	public dynamic function selfRender(frameBuffer:FrameBuffer, atx:Float, aty:Float) {}

	/**
		Render the object and all its children

		@param frameBuffer Frame buffer to render to
		@param atx Screen X position to render
		@param aty Screen Y position to render
	 */
	function renderObject(frameBuffer:FrameBuffer, atx:Float, aty:Float) {
		selfRender(frameBuffer, atx, aty);

		for (child in children)
			child.renderObject(frameBuffer, atx + child.x, aty + child.y);
	}

	override function render(frameBuffer:FrameBuffer) {
		renderObject(frameBuffer, x, y);
	}

	public function update(dt:Float) {
		for (child in children)
			child.update(dt);
	}
}
