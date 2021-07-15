package res.devtools.tilemaps;

import res.input.Key;
import res.tiles.Tilemap;
import res.tiles.Tileset;
import res.tools.MathTools.wrapi;

class TilemapEditor extends Scene {
	var uiTileset:Tileset;

	var bgTilemap:Tilemap;

	var frontTilemap:Tilemap;

	var cursorX:Int = 0;
	var cursorY:Int = 0;

	final tilemap:Tilemap;

	public function new(res:Res, tilemap:Tilemap) {
		super(res);

		this.tilemap = tilemap;

		uiTileset = res.createTileset(8, 8, tilemap.tileset.tileSize);

		var gridTile = uiTileset.pushTile();
		gridTile.indecies.set(0, 1);

		var cursorTile = uiTileset.pushTile();
		cursorTile.fill(1);

		bgTilemap = res.createTilemap(uiTileset, tilemap.hTiles, tilemap.hTiles, [res.palette.brightestIndex]);
		bgTilemap.fill(1);

		frontTilemap = res.createTilemap(uiTileset, tilemap.hTiles, tilemap.vTiles, [res.palette.brightestIndex]);
		frontTilemap.set(0, 0, 2);

		renderList.push(bgTilemap);
		renderList.push(tilemap);
		renderList.push(frontTilemap);
	}

	function moveCursor(dx:Int, dy:Int) {
		frontTilemap.set(cursorX, cursorY, 0);

		cursorX = wrapi(cursorX + dx, tilemap.hTiles);
		cursorY = wrapi(cursorY + dy, tilemap.vTiles);

		frontTilemap.set(cursorX, cursorY, 2);
	}

	function setTile(index:Int) {
		tilemap.set(cursorX, cursorY, index);
	}

	override function keyDown(keyCode:Int) {
		switch (keyCode) {
			case Key.LEFT | Key.H:
				moveCursor(-1, 0);
			case Key.RIGHT | Key.L:
				moveCursor(1, 0);
			case Key.UP | Key.K:
				moveCursor(0, -1);
			case Key.DOWN | Key.J:
				moveCursor(0, 1);
			case Key.SPACE:
				setTile(Std.int(Math.random() * tilemap.tileset.numTiles));
		}
	}

	override function keyPress(charCode:Int) {
		switch (String.fromCharCode(charCode)) {
			case '?':
				trace('Show tiles palette?');
			case ':':
				trace('Show command palette');
		}
	}

	override function update(dt:Float) {
		super.update(dt);
	}
}
