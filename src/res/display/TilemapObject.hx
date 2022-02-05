package res.display;

import res.tiles.Tilemap;

class TilemapObject extends Object {
	public final tilemap:Tilemap;

	public function new(tilemap:Tilemap) {
		this.tilemap = tilemap;
		autosize();
	}

	public function autosize() {
		this.width = tilemap.pixelWidth;
		this.height = tilemap.pixelHeight;
	}

	override function selfRender(frameBuffer:FrameBuffer, atx:Float, aty:Float) {
		Tilemap.drawTilemap(frameBuffer, tilemap, Math.floor(atx), Math.floor(aty), Math.floor(width), Math.floor(height), Math.floor(scrollX),
			Math.floor(scrollY));
	}
}
