package res;

import haxe.macro.Context;
import sys.io.File;

class Rom {
	public static macro function init(src:String, out:String) {
		Context.onGenerate((_) -> {
			File.append('log.log', false).writeString('${Sys.args()}\n');

			if (Sys.args().indexOf("--no-output") == -1) {
				trace('Creating ROM');

				if (!sys.FileSystem.exists(src))
					throw 'Error: $src doesn\'t exists';

				var rom = new haxe.zip.Writer(sys.io.File.write(out));

				var files:List<haxe.zip.Entry> = new List<haxe.zip.Entry>();

				var log = File.append('/home/michael/res-openfl-test/log.log');

				var defines:Map<String, String> = haxe.macro.Context.getDefines();

				log.writeString('$defines\n');

				for (dir in sys.FileSystem.readDirectory(src)) {
					final path = haxe.io.Path.join([src, dir]);

					if (sys.FileSystem.isDirectory(path)) {
						for (file in sys.FileSystem.readDirectory(path)) {
							var filePath = haxe.io.Path.join([path, file]);
							if (!sys.FileSystem.isDirectory(filePath)) {
								var fileData = sys.io.File.getBytes(filePath);

								files.add({
									fileTime: Date.now(),
									fileName: haxe.io.Path.join([dir, file]),
									fileSize: fileData.length,
									dataSize: fileData.length,
									data: fileData,
									crc32: haxe.crypto.Crc32.make(fileData),
									compressed: false
								});
							}
						}
					}
				}

				rom.write(files);
			}
		});
		return macro trace('Init ROM');
	}
}
