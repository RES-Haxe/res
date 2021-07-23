package res.devtools.tilesets;

import res.ui.Menu;
import res.ui.MenuScene;

class TilesetMenu extends MenuScene {
	public function new(res:RES) {
		var menu = new Menu(res.createDefaultTextmap([res.palette.brightestIndex]));

		for (name => tileset in res.rom.tilesets) {
			menu.addItem(name, () -> {
				res.popScene(tileset);
			});
		}

		menu.addItem('[ < Back ]', () -> {
			res.popScene();
		});

		super(res, menu);
	}
}
