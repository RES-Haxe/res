package res.devtools.tilemaps;

import res.ui.Menu;
import res.ui.MenuItem;
import res.ui.MenuScene;
import res.ui.ValueInputScene;

class TilemapSettings extends MenuScene {
	var text:Textmap;

	var tilemapName:String = 'new_tilemap';
	var hTiles:Int = 8;
	var vTiles:Int = 8;

	var nameItem:MenuItem;
	var hTilesItem:MenuItem;
	var vTilesItem:MenuItem;

	public function new(res:Res, tileset:Tileset) {
		var menu = new Menu(res.createDefaultTextmap([res.palette.brightestIndex]));

		nameItem = menu.addItem('', () -> {
			res.pushScene(ValueInputScene, ['Name', tilemapName], true, (value:String) -> {
				tilemapName = value;
				updateText();
			});
		});

		hTilesItem = menu.addItem('', () -> {
			res.pushScene(ValueInputScene, ['Hor. Tiles', '$hTiles'], true, (value:String) -> {
				hTiles = Std.parseInt(value);
				updateText();
			});
		});

		vTilesItem = menu.addItem('', () -> {
			res.pushScene(ValueInputScene, ['Vert. Tiles', '$vTiles'], true, (value:String) -> {
				vTiles = Std.parseInt(value);
				updateText();
			});
		});

		menu.addItem('[ OK ]', () -> {
			var tilemap = res.createTilemap(tilemapName, tileset, hTiles, vTiles);
			res.popScene(tilemap);
		});

		menu.addItem('[ CANCEL ]', () -> {
			res.popScene();
		});

		super(res, menu);

		updateText();
	}

	function updateText() {
		nameItem.text = 'Name       : $tilemapName';
		hTilesItem.text = 'Hor. Tiles : $hTiles';
		vTilesItem.text = 'Vert. Tiles: $vTiles';
		menu.updateText();
	}
}
