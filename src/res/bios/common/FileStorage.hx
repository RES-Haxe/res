package res.bios.common;

import haxe.Json;
import res.storage.Storage;
import sys.FileSystem;
import sys.io.File;

using Reflect;

class FileStorage extends Storage {
	var fileName:String;

	public function new(?fileName:String = 'data.dat') {
		super();

		this.fileName = fileName;
	}

	override public function save() {
		File.saveContent(fileName, Json.stringify(data));
	}

	override public function restore() {
		if (FileSystem.exists(fileName))
			data = Json.parse(File.getContent(fileName));
	}
}
