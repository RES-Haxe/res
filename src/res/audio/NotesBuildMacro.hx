package res.audio;

import haxe.macro.Context;
import haxe.macro.Expr.Field;

using StringTools;

class NotesBuildMacro {
	macro static public function build():Array<Field> {
		var fields = Context.getBuildFields();

		final baseNote = 55.0; // A1

		for (octave in 1...9) {
			for (n => notes in [['A'], ['As', 'Bb'], ['B'], ['C'], ['Cs', 'Db'], ['D'], ['Ds', 'Eb'], ['E'], ['F'], ['Fs', 'Gb'], ['G'], ['Gs', 'Ab']]) {
				for (note in notes) {
					fields.push({
						name: '$note$octave',
						doc: note.replace('s', '#') + ' at $octave octave',
						meta: [],
						access: [AStatic, APublic],
						kind: FVar(macro:Float, macro $v{baseNote * Math.pow(2, ((octave - 1) * 12 + n) / 12)}),
						pos: Context.currentPos()
					});
				}
			}
		}

		return fields;
	}
}
