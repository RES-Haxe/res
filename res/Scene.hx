package res;

class Scene {
	@:allow(res)
	var res:Res;

	public final renderList:Array<Renderable> = [];

	public function new(res:Res) {
		this.res = res;
	}

	public function keyDown(keyCode:Int) {}

	public function keyPress(charCode:Int) {}

	public function keyUp(keyCode:Int) {}

	public function update(dt:Float) {}
}
