package res;

import haxe.io.Bytes;

interface Renderable {
	function render(frameBuffer:Bytes, frameWidth:Int, frameHeight:Int):Void;
}
