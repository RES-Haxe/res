package res.features.devtools.sprites;

import res.ui.Menu;
import res.ui.MenuScene;

class SpritesMenu extends MenuScene {
	public function new(res:RES) {
		menu = new Menu();

		menu.addItem('[ + Create ]', () -> {});

		for (name => sprite in res.rom.sprites) {
			menu.addItem('$name (${sprite.width}x${sprite.height})', () -> {
				// TODO
			});
		}

		menu.addItem('[ ← Back ]', () -> {
			res.popScene();
		});

		super(res, menu);
	}
}