package res;

class Scene implements Renderable implements Updateable {
	@:allow(res)
	var res:Res;

	public final renderList:Array<Renderable> = [];

	public function new(res:Res) {
		this.res = res;
	}

	public function keyDown(keyCode:Int) {}

	public function keyPress(charCode:Int) {}

	public function keyUp(keyCode:Int) {}

	public function update(dt:Float) {
		// TODO: Not optimal
		for (item in renderList)
			if (Std.isOfType(item, Updateable))
				cast(item, Updateable).update(dt);
	}

	public function render(frameBuffer:FrameBuffer) {
		for (renderable in renderList)
			renderable.render(frameBuffer);
	}
}
