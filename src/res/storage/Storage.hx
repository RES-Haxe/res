package res.storage;

class Storage {
	var data:Map<String, Dynamic> = [];

	public function new() {}

	public function put(key:String, d:Dynamic) {
		data[key] = d;
	}

	public function get(key:String):Dynamic {
		return data[key];
	}

	public function getBool(key:String, ?defaultValue:Bool = false):Null<Bool> {
		final val = get(key);
		return val == null ? defaultValue : val;
	}

	public function getString(key:String, ?defaultValue:String):String {
		final val = get(key);
		return val == null ? defaultValue : val;
	}

	public function getInt(key:String, ?defaultValue:Int):Null<Int> {
		final val = get(key);
		return val == null ? defaultValue : cast data[key];
	}

	public function getFloat(key:String, ?defaultValue:Float):Null<Float> {
		final val = get(key);
		return val == null ? defaultValue : cast data[key];
	}

	public function save() {}

	public function restore() {}
}
