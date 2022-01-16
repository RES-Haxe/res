package res.bios.common;

import haxe.Json;
import res.storage.IStorage;
import sys.FileSystem;
import sys.io.File;

using Reflect;

class FileStorage implements IStorage {
	var storage:Dynamic<String>;
	var fileName:String;

	public function new(?fileName:String = 'data.dat') {
		this.fileName = fileName;

		if (FileSystem.exists(fileName)) {
			this.storage = Json.parse(File.getContent(fileName));
		} else {
			this.storage = {};
		}
	}

	public function put(key:String, data:Dynamic) {
		storage.setField(key, data);
	}

	public function get(key:String):Dynamic {
		return storage.getProperty(key);
	}

	public function getString(key:String, ?defaultValue:String):String {
		final stored = get(key);
		return stored == null ? defaultValue : '$stored';
	}

	public function getInt(key:String, ?defaultValue:Int):Null<Int> {
		final stored = get(key);
		return stored == null ? defaultValue : Std.parseInt('$stored');
	}

	public function getFloat(key:String, ?defaultValue:Float):Null<Float> {
		final stored = get(key);
		return stored == null ? defaultValue : Std.parseFloat('$stored');
	}
}
