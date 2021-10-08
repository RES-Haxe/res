package res;

interface IFrameBuffer {
	var frameWidth(get, never):Int;
	var frameHeight(get, never):Int;

	function beginFrame():Void;
	function clear(index:Int):Void;
	function endFrame():Void;
	function getIndex(x:Int, y:Int):Int;
	function setIndex(x:Int, y:Int, index:Int):Void;
}
