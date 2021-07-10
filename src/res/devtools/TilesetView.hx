package res.devtools;

import res.input.Key;

using Std;

class TilesetView extends Scene {
	var tilemap:Tilemap;

	public function new(res:Res, tileset:Tileset) {
		super(res);

		var indecies = res.palette.byLuminance.copy();
		indecies.reverse();

		var screenHTiles:Int = (res.frameBuffer.frameWidth / tileset.tileSize).int();
		var screenVTiles:Int = (res.frameBuffer.frameHeight / tileset.tileSize).int();

		tilemap = res.createTilemap(tileset, Math.max(screenHTiles, tileset.hTiles).int(), Math.max(screenVTiles, tileset.vTiles).int(), indecies);

		var tileIndex:Int = 0;
		for (line in 0...tileset.vTiles) {
			for (col in 0...tileset.hTiles) {
				if (tileIndex < tileset.numTiles) {
					tilemap.set(col, line, 1 + tileIndex);
					tileIndex++;
				} else
					break;
			}
		}

		renderList.push(tilemap);
	}

	override function update(dt:Float) {
		if (res.keyboard.isDown(Key.DOWN))
			tilemap.scrollY += 1;
		if (res.keyboard.isDown(Key.UP))
			tilemap.scrollY -= 1;
		if (res.keyboard.isDown(Key.LEFT))
			tilemap.scrollX -= 1;
		if (res.keyboard.isDown(Key.RIGHT))
			tilemap.scrollX += 1;
	}
}