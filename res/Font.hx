package res;

import haxe.io.Bytes;

class Font {
	public var data:Bytes;
	public var characters:String;
	public var srcWidth:Int;
	public var srcHeight:Int;

	public function new(data:Bytes, characters:String, srcWidth:Int, srcHeight:Int) {
		this.data = data;
		this.characters = characters;
		this.srcWidth = srcWidth;
		this.srcHeight = srcHeight;
	}
}
