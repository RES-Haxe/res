package res.devtools.sprites;

import res.ui.Menu;

class SpritesMenu extends Scene {
	var menu:Menu;

	public function new(res:Res) {
		super(res);

		menu = new Menu(res.createDefaultTextmap([res.palette.brightestIndex]));

		menu.addItem('[ + Create ]', () -> {});
		// TODO: List sprites here
		menu.addItem('[ ← Back ]', () -> {
			res.popScene();
		});

		renderList.push(menu);
	}

	override function keyDown(keyCode:Int) {
		menu.keyDown(keyCode);
	}
}
