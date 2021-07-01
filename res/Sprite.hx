package res;

class Sprite {
	public var x:Float;
	public var y:Float;

	public final frames:Array<SpriteFrame> = [];

	public var hTiles:Int;
	public var vTiles:Int;

	public var tileset:Tileset;

	public var paletteSample:PaletteSample;

	public var currentFrame(get, never):SpriteFrame;

	function get_currentFrame():SpriteFrame
		return frames[0];

	var res:Res;

	@:allow(res)
	private function new(res:Res, tileset:Tileset, hTiles:Int, vTiles:Int, ?paletteSample:PaletteSample) {
		this.res = res;

		this.tileset = tileset;

		this.hTiles = hTiles;
		this.vTiles = vTiles;

		this.paletteSample = paletteSample;
	}

	public function addFrame(tileIndecies:Array<Int>, duration:Int) {
		frames.push(new SpriteFrame(tileIndecies, duration));
	}
}
