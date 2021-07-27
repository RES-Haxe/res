package res.ui;

class MenuScene extends Scene {
	var menu:Menu;

	public function new(res:RES, menu:Menu) {
		super(res);

		renderList.push(this.menu = menu);
	}

	override function keyDown(keyCode:Int) {
		menu.keyDown(keyCode);
	}
}
