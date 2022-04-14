package res.tools;

class ReflectTools {
	public static function setValues(dest:Dynamic, src:Dynamic) {
		for (field in Reflect.fields(src)) {
			if (Reflect.hasField(dest, field)) {
				Reflect.setField(dest, field, Reflect.field(src, field));
			}
		}
	}
}
