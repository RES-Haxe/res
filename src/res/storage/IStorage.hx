package res.storage;

interface IStorage {
	function put(key:String, data:Dynamic):Void;

	function get(key:String):Dynamic;

	function getString(key:String, ?defaultValue:String):String;

	function getInt(key:String, ?defaultValue:Int):Null<Int>;

	function getFloat(key:String, ?defaultValue:Float):Null<Float>;
}
