package res.devtools;

class TilesetView extends Scene {
	public function new(res:Res, tileset:Tileset) {
		super(res);

		var indecies = res.palette.byLuminance.copy();
		indecies.reverse();

		var tilemap = res.createTilemap(tileset, indecies);

		var tileIndex:Int = 0;
		for (line in 0...tilemap.vTiles) {
			for (col in 0...tilemap.hTiles) {
				if (tileIndex < tileset.numTiles) {
					tilemap.set(col, line, 1 + tileIndex);
					tileIndex++;
				} else
					break;
			}
		}

		renderList.push(tilemap);
	}
}
