package res.input;

import haxe.macro.Context;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.Function;

class ControllerBuildMacro {
	macro public static function build():Array<Field> {
		var fields = Context.getBuildFields();

		for (btn in Type.allEnums(ControllerButton).map(v -> v.getName())) {
			var getFunc:Function = {
				args: [],
				expr: Context.parse('return this.pressed[ControllerButton.${btn}]', Context.currentPos()),
				ret: (macro :Bool)
			};

			fields.push({
				name: btn.toLowerCase(),
				pos: Context.currentPos(),
				access: [APublic],
				kind: FProp('get', 'never', macro :Bool),
				doc: 'State of the ${btn} button'
			});

			fields.push({
				name: 'get_${btn.toLowerCase()}',
				pos: Context.currentPos(),
				kind: FFun(getFunc),
			});
		}

		return fields;
	}
}
