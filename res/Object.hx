package res;

class Object {
	public var x:Float = 0;
	public var y:Float = 0;

	public var priority:Null<Int> = null;

	public final sprite:Sprite;

	public final paletteIndecies:Array<Int>;

	public var currentFrame(get, never):SpriteFrame;

	function get_currentFrame():SpriteFrame
		return sprite.frames[0];

	public inline function new(sprite:Sprite, paletteIndecies:Array<Int>) {
		this.sprite = sprite;
		this.paletteIndecies = paletteIndecies;
	}
}
