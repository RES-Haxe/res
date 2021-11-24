package res.platforms.js;

import haxe.Json;
import js.Browser;
import res.storage.StorageBase;

class Html5Storage extends StorageBase {
	override function put(key:String, d:Dynamic) {
		Browser.getLocalStorage().setItem(key, Json.stringify(d));
	}

	override function get(key:String):Dynamic {
		final data = Browser.getLocalStorage().getItem(key);

		if (data != null) {
			return Json.parse(data);
		} else
			return null;
	}
}
