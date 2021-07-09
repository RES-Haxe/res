package res.devtools.sprites;

import res.ui.MenuScene;
import res.ui.Menu;

class SpritesMenu extends MenuScene {
	public function new(res:Res) {
		menu = new Menu(res.createDefaultTextmap([res.palette.brightestIndex]));

		menu.addItem('[ + Create ]', () -> {});

		for (name => sprite in res.sprites) {
			menu.addItem(name, () -> {
				// TODO
			});
		}

		menu.addItem('[ ← Back ]', () -> {
			res.popScene();
		});

		super(res, menu);
	}
}
