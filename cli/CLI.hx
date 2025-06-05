package cli;

import Sys.print;
import Sys.println;
import haxe.Json;

using StringTools;

enum ArgType {
	STRING;
	INT;
	FLOAT;
	BOOL;
	ENUM(values:Array<String>);
	MULTIPLE(values:Array<String>);
}

typedef Argument = {
	?defaultValue:(?prev:Map<String, String>) -> String,
	?example:String,
	?name:String,
	?validator:(value:String) -> {result: Bool, msg: String},
	desc:String,
	interactive:Bool,
	requred:Bool,
	type:ArgType,
};

inline function wrap(x, w)
	return x < 0 ? w + (x % w) : x >= w ? x % w : x;

function selectionMenu(values:Array<String>, ?preselected:Array<String>, ?multiple:Bool = true) {
	final selected:Array<String> = preselected != null ? preselected : [];
	var itemIndex:Int = 0;

	final BO = multiple ? '[' : '(';
	final BC = multiple ? ']' : ')';
	final BU = multiple ? 'x' : '*';
	final instructions = (() -> {
		final parts = ['[up]/[down]: choose'];
		if (multiple)
			parts.push('[space]: select/deselect');
		parts.push('[enter]: done');
		parts.push('[q]: quit');
		return parts.join(', ');
	})();

	final setSingle = function() {
		if (multiple)
			return;
		final val = values[itemIndex];
		if (selected.length == 0)
			selected.push(val);
		else
			selected[0] = val;
	};

	while (true) {
		for (n in 0...values.length) {
			final val = values[n];
			final isSelected = selected.indexOf(val) != -1;
			final current = n == itemIndex;
			println('${current ? '>' : ' '} ${BO}${isSelected ? BU : current ? '_' : ' '}${BC} $val');
		}

		println(instructions);
		final char = Sys.getChar(false);

		switch (char) {
			case 13:
				break;
			case 32:
				if (multiple) {
					final val = values[itemIndex];
					final idx = selected.indexOf(val);
					if (idx == -1)
						selected.push(val);
					else
						selected.splice(idx, 1);
				}
			case 65 | 66:
				itemIndex = wrap(itemIndex + (char == 65 ? -1 : 1), values.length);
				setSingle();
			case 113:
				return null;
		}

		for (_ in 0...(values.length + 1))
			print('\033[1A');
	}

	// Preserve the order
	selected.sort((a, b) -> values.indexOf(a) - values.indexOf(b));

	return selected;
}

function ask(arg:Argument):String {
	final defaultAnswer = arg.defaultValue != null ? arg.defaultValue() : null;

	final info = switch arg.type {
		case BOOL:
			defaultAnswer == null ? 'y/n' : defaultAnswer.toLowerCase() == 'y' ? 'Y/n' : 'y/N';
		case ENUM(_):
			null;
		case MULTIPLE(_):
			null;
		case _:
			defaultAnswer;
	};

	print('${arg.desc}${info != null ? ' [$info]' : ''}: ');

	while (true) {
		final result:Null<String> = switch (arg.type) {
			case BOOL:
				final ans = Sys.stdin().readLine().trim();
				final result = ["y", "yes", "true", "1"].indexOf(ans.toLowerCase()) != -1;
				return result ? "true" : "false";
			case ENUM(values):
				println('');
				final preselect:Array<String> = [defaultAnswer];
				final result = selectionMenu(values, preselect, false);
				if (result == null)
					Sys.exit(0);
				result[0];
			case MULTIPLE(values):
				println('');
				final preselect:Array<String> = Json.parse(defaultAnswer);
				final result = selectionMenu(values, preselect);
				if (result == null)
					Sys.exit(0);
				Json.stringify(result);
			case _:
				final input = Sys.stdin().readLine().trim();
				if (input.length == 0) {
					if (defaultAnswer != null)
						defaultAnswer;
					else
						ask(arg);
				} else input;
		}

		var valResult;
		if (arg.validator == null || (valResult = arg.validator(result)).result)
			return result;
		else
			println(valResult.msg);
	}

	return null;
}

function ask_yn(text:String, ?def:Bool = false):Bool {
	return ask({
		desc: text,
		type: BOOL,
		defaultValue: (?p) -> def ? 'y' : 'n',
		requred: true,
		interactive: true
	}) == "true";
}

function getArguments(args:Array<String>, expect:Array<Argument>):Map<String, String> {
	final result:Map<String, String> = [];

	args = args.filter(arg -> {
		if (arg.startsWith('--')) {
			final parts = arg.split('=');
			final paramName = parts[0].substr(2).trim();

			if (paramName != '') {
				result[paramName] = parts[1];
			}

			return false;
		}
		return true;
	});

	for (nArg in 0...expect.length) {
		if (result.exists(expect[nArg].name))
			continue;

		result[expect[nArg].name] = if (nArg >= args.length) {
			final arg = expect[nArg];
			if (arg.requred) {
				if (arg.interactive)
					ask(arg);
				else
					arg.defaultValue(result);
			} else if (arg.defaultValue != null)
				arg.defaultValue(result);
			else
				null;
		} else {
			args[nArg];
		}
	}

	return result;
}

function printTable(rows:Array<Array<String>>, gap:Int = 1, separator:String = '', useHeaders:Bool = false) {
	if (rows.length == 0)
		return;

	final col_num = rows[0].length;

	for (row in rows)
		if (row.length != col_num)
			throw "All rows must have the same amount of columns";

	final max_lengths:Array<Int> = [for (_ in 0...col_num) 0];

	for (row in rows) {
		for (n_col => col in row) {
			max_lengths[n_col] = Std.int(Math.max(col.length, max_lengths[n_col]));
		}
	}

	if (useHeaders) {
		rows.insert(1, [for (n in 0...col_num) ''.rpad('-', max_lengths[n])]);
	}

	for (row in rows) {
		for (n_col => col in row) {
			print('${col.rpad(' ', max_lengths[n_col])}${n_col < row.length - 1 ? separator : ''}${''.lpad(' ', gap)}');
		}
		print('\n');
	}
}

/**
	Print the text wrapped

	@param text Text to print
	@param pad Padding
	@param maxCols Total maximum columns including the padding
	@param cont Continue output or start as a new line
**/
function printWrapped(text:String, pad:Int = 0, ?maxCols:Int = 80, ?cont:Bool = false) {
	final words = text.split(' ');

	while (words.length > 0) {
		var currentLine = cont ? '' : ''.lpad(' ', pad);
		cont = false;

		while (words.length > 0 && '$currentLine${words[0]}'.length < maxCols) {
			currentLine = '$currentLine${words[0]} ';
			words.shift();
		}
		Sys.println(currentLine.rtrim());
	}
}

function error(message:String) {
	Sys.stderr().writeString('Error: $message\n');
	Sys.exit(1);
}
