package res;

class SpriteFrame {
	public var indecies:Array<Int>;
	public var duration:Int;

	public function new(tileIndecies:Array<Int>, duration:Int) {
		this.indecies = tileIndecies;
		this.duration = duration;
	}
}
