package res.display;

using Math;

class Object {
	public var x:Float = 0;
	public var y:Float = 0;

	public var width:Float = 0;
	public var height:Float = 0;

	public var scrollX:Float = 0;
	public var scrollY:Float = 0;

	public var colorMap:ColorMap = null;

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

	public function render(frameBuffer:FrameBuffer) {
		renderObject(frameBuffer, x, y);
	}

	public function update(dt:Float) {
		for (child in children)
			child.update(dt);
	}
}
