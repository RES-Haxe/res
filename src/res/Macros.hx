package res;

import sys.io.File;
import haxe.Json;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;

class Macros {
	public static function ver():Array<Field> {
		var posInfos = Context.getPosInfos(Context.currentPos());
		var haxelibFile = Path.normalize(Path.join([Path.directory(posInfos.file), '..', '..', 'haxelib.json']));

		var haxelib = Json.parse(File.getContent(haxelibFile));

		var fields = Context.getBuildFields();

		fields.push({
			name: 'VERSION',
			access: [Access.APublic, Access.AStatic, Access.AInline],
			kind: FieldType.FVar(macro:String, macro $v{haxelib.version}),
			pos: Context.currentPos()
		});

		return fields;
	}
}
