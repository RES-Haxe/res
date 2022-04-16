package res.bios.common;

import sys.FileSystem;
import haxe.Json;
import res.storage.Storage;
import sys.io.File;

using Reflect;

class FileStorage extends Storage {
	var fileName:String;

	public function new(?fileName:String = 'data.dat') {
		super();

		this.fileName = fileName;
	}

	public function save() {
		File.saveContent(fileName, Json.stringify(data));
	}

	public function restore() {
		if (FileSystem.exists(fileName))
			data = Json.parse(File.getContent(fileName));
	}
}
