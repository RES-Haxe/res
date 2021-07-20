package tools;

import ase.Ase;
import haxe.io.Bytes;
import sys.io.File;

using Lambda;

class Main {
	static function generateResources() {
		final fonts:Array<{haxeFilename:String, aseFilename:String, className:String}> = [
			{haxeFilename: 'src/res/data/Pico8FontData.hx', aseFilename: 'resources/pico8_font.aseprite', className: 'Pico8FontData'},
			{
				haxeFilename: 'src/res/data/CommodorKernalFontData.hx',
				aseFilename: 'resources/commodor_kernal_font.aseprite',
				className: 'CommodorKernalFontData'
			}
		];

		for (font in fonts) {
			final aseFilename = font.aseFilename;
			final haxeFilename = font.haxeFilename;
			final className = font.className;

			final ase = Ase.fromBytes(File.getBytes(aseFilename));

			var cel = ase.firstFrame.cel(0);
			var pixelData = cel.pixelData;

			var data = Bytes.alloc(ase.width * ase.height);

			data.fill(0, data.length, 0);

			for (line in 0...cel.height) {
				var in_line:Int = cel.yPosition + line;

				data.blit(ase.width * in_line + cel.xPosition, pixelData, line * cel.width, cel.width);
			}

			var lines:Array<Array<Int>> = [[]];

			for (n in 0...data.length) {
				var lineIndex:Int = lines.length - 1;
				var byte = data.get(n);

				if (lines[lineIndex].length < 32)
					lines[lineIndex].push(byte);
				else
					lines.push([byte]);
			}

			var dataString:String = lines.map(line -> line.join(', ')).join(',\n');

			final hxFile = File.write(haxeFilename, false);

			hxFile.writeString('/**\nTHIS FILE WAS GENERATED WITH `haxelib run res gen`. PLEASE DON\'T CHANGE\n*/\n');
			hxFile.writeString('package res.data;\n\n');
			hxFile.writeString('import haxe.io.Bytes;\n');
			hxFile.writeString('import haxe.io.UInt8Array;\n\n');
			hxFile.writeString('class $className {\n');
			hxFile.writeString('\tpublic static final WIDTH:Int = ${ase.width};\n');
			hxFile.writeString('\tpublic static final HEIGHT:Int = ${ase.height};\n');
			hxFile.writeString('\tpublic static final TILE_SIZE:Int = ${ase.header.gridWidth};\n');
			hxFile.writeString('\tpublic static final H_TILES:Int = ${Std.int(ase.width / ase.header.gridWidth)};\n');
			hxFile.writeString('\tpublic static final V_TILES:Int = ${Std.int(ase.height / ase.header.gridWidth)};\n');
			hxFile.writeString('\tpublic static final DATA:Bytes = UInt8Array.fromArray([\n$dataString\n]).view.buffer;\n');
			hxFile.writeString('}\n');
		}

		final splashAse = Ase.fromBytes(File.getBytes('resources/splash.aseprite'));

		final cel = splashAse.firstFrame.cel(0);

		final dataString:String = cel.pixelData.toHex();

		final hxFile = File.write('src/res/data/SplashData.hx', false);

		hxFile.writeString('/**\nTHIS FILE WAS GENERATED WITH `haxelib run res gen`. PLEASE DON\'T CHANGE\n*/\n');
		hxFile.writeString('package res.data;\n\n');
		hxFile.writeString('import haxe.io.Bytes;\n');
		hxFile.writeString('class SplashData {\n');
		hxFile.writeString('\tpublic static final WIDTH:Int = ${cel.width};\n');
		hxFile.writeString('\tpublic static final HEIGHT:Int = ${cel.height};\n');
		hxFile.writeString('\tpublic static final DATA:Bytes = Bytes.ofHex(\'${dataString}\');\n');
		hxFile.writeString('}\n');
	}

	static function main() {
		final args = Sys.args();

		if (args.length >= 2) {
			switch (args[0]) {
				case 'gen':
					generateResources();
			}
		}
	}
}
