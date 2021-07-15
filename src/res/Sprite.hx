package res;

import res.tiles.Tileset;

class Sprite {
	public final frames:Array<SpriteFrame> = [];

	public var hTiles:Int;
	public var vTiles:Int;
	public var tileset:Tileset;

	var res:Res;

	@:allow(res)
	private function new(res:Res, tileset:Tileset, hTiles:Int, vTiles:Int) {
		this.res = res;

		this.tileset = tileset;

		this.hTiles = hTiles;
		this.vTiles = vTiles;
	}

	public function addFrame(tileIndecies:Array<Int>, duration:Int) {
		frames.push(new SpriteFrame(tileIndecies, duration));
	}
}
