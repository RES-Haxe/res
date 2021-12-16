package res.rom.converters.palette.text;

import sys.io.File;

class Converter extends PaletteConverter {
	override function process(fileName:String) {
		final file = File.read(fileName, false);

		while (colors.length < 256 && !file.eof()) {
			var colStr:String = file.readLine();

			if (colStr.substr(0, 2) == '--') // comment
				continue;

			if (colStr.charAt(0) == '#')
				colStr = colStr.substr(1);

			if (colStr.substr(0, 2) == '0x')
				colStr = colStr.substr(2);

			colors.push(Std.parseInt('0x$colStr'));
		}

		return this;
	}
}
