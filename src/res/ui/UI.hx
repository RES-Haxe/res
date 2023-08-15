package res.ui;

import res.Bitmap;

using res.Paint;

typedef UIUpdateResult = {mouseIn:Bool, mouseDown:Bool, mouseUp:Bool};
typedef UIMouseData = {x:Int, y:Int, isDown:Bool};

enum UIMouseEvent {
	mouseIn;
	mouseOut;
	mouseDown;
	mouseUp;
}

class UI {
	public var id:String;

	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;

	private var parent:UI;

	public var mouseIsOver:Bool = false;
	public var mouseIsDown:Bool = false;

	private final children:Array<UI> = [];
	private final prevState:UIMouseData = {x: 0, y: 0, isDown: false};

	public function new(?id:String, x:Int, y:Int, width:Int, height:Int) {
		this.id = id;
		setBounds(x, y, width, height);
	}

	public function gx():Int
		return parent == null ? x : parent.gx() + x;

	public function gy():Int
		return parent == null ? y : parent.gy() + y;

	/**
		Add an element to the tree
	**/
	public function add(child:UI, ?x:Int, ?y:Int) {
		if (children.indexOf(child) != -1)
			return;

		child.x = x == null ? child.x : x;
		child.y = y == null ? child.y : y;
		child.parent = this;
		children.push(child);
	}

	/**
		Remove element from children
	**/
	public function remove(child:UI) {
		child.parent = null;
		children.remove(child);
	}

	/**
		Draw the element itself
	**/
	public dynamic function drawElement(surface:Bitmap, self:UI, bounds:{
		x:Int,
		y:Int,
		width:Int,
		height:Int
	}) {}

	public dynamic function onMouseIn(x:Int, y:Int):Bool
		return false;

	public dynamic function onMouseOut(x:Int, y:Int):Bool
		return false;

	public dynamic function onMouseDown(x:Int, y:Int):Bool
		return false;

	public dynamic function onMouseUp(x:Int, y:Int):Bool
		return false;

	public function setBounds(x:Int, y:Int, width:Int, height:Int) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	private function processMouseEvent(event:UIMouseEvent, mouse:UIMouseData):Bool {
		function processedByChild(event:UIMouseEvent) {
			var result = false;
			for (child in children)
				if (child.processMouseEvent(event, {x: mouse.x - x, y: mouse.y - y, isDown: mouse.isDown}))
					result = true;
			return result;
		}

		if (processedByChild(event))
			return true;

		final inside = !(mouse.x < x || mouse.x > x + width || mouse.y < y || mouse.y > y + height);

		if (event == mouseOut && mouseIsOver && !inside) {
			mouseIsOver = false;
			return onMouseOut(mouse.x, mouse.y);
		}

		if (!inside)
			return false;

		if (event == mouseIn && !mouseIsOver) {
			mouseIsOver = true;
			return onMouseIn(mouse.x, mouse.y);
		}

		if (event == mouseDown && mouse.isDown && !mouseIsDown) {
			mouseIsDown = true;
			return onMouseDown(mouse.x, mouse.y);
		}

		if (event == mouseUp && !mouse.isDown && mouseIsDown) {
			mouseIsDown = false;
			return onMouseUp(mouse.x, mouse.y);
		}

		return false;
	}

	public function update(mouse:UIMouseData) {
		if (mouse.x != prevState.x || mouse.y != prevState.y)
			for (event in [mouseOut, mouseIn])
				processMouseEvent(event, mouse);

		if (mouse.isDown && !prevState.isDown)
			processMouseEvent(mouseDown, mouse);

		if (!mouse.isDown && prevState.isDown)
			processMouseEvent(mouseUp, mouse);

		prevState.x = mouse.x;
		prevState.y = mouse.y;
		prevState.isDown = mouse.isDown;
	}

	/**
		Draw the whole tree of elements
	**/
	public function draw(surface:Bitmap) {
		drawElement(surface, this, {
			x: gx(),
			y: gy(),
			width: width,
			height: height
		});

		for (child in children)
			child.draw(surface);
	}
}
