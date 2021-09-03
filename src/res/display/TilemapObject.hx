package res.display;

import res.tiles.Tilemap;

class TilemapObject extends Object {
	public final tilemap:Tilemap;

	public function new(tilemap:Tilemap) {
		this.tilemap = tilemap;
		autosize();
	}

	public function autosize() {
		this.width = tilemap.hTiles * tilemap.tileset.tileSize;
		this.height = tilemap.vTiles * tilemap.tileset.tileSize;
	}

	override function selfRender(frameBuffer:FrameBuffer, atx:Float, aty:Float) {
		Tilemap.drawTilemap(tilemap, frameBuffer, Math.floor(atx), Math.floor(aty), Math.floor(width), Math.floor(height), Math.floor(scrollX),
			Math.floor(scrollY));
	}
}
