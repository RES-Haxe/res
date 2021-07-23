package res.ui;

class MenuScene extends Scene {
	var menu:Menu;

	public function new(res:RES, menu:Menu) {
		super(res);

		renderList.push(this.menu = menu);
	}

	override function keyDown(keyCode:Int) {
		switch (keyCode) {
			case 13:
				menu.execute();
			case 38 | 87 | 75:
				menu.selectedIndex--;
			case 40 | 83 | 74:
				menu.selectedIndex++;
		}
	}
}
