package cli.common;

import sys.FileSystem;
import sys.io.File;

using StringTools;

enum HxmlElement {
	FILE(name:String);
	SWITCH(name:String, value:String);
}

class Hxml {
	final elements:Array<HxmlElement> = [];

	public function add(element:HxmlElement) {
		elements.push(element);
	}

	public function getSwitch(name:String):Array<String> {
		final result:Array<String> = [];

		for (element in elements) {
			switch (element) {
				case SWITCH(swcName, value):
					if (swcName == name)
						result.push(value);
				case _:
			}
		}

		return result;
	}

	public function toString():String {
		final strings:Array<String> = [];

		for (element in elements) {
			switch (element) {
				case FILE(name):
					strings.push(name);
				case SWITCH(name, value):
					strings.push('-$name $value');
			}
		}

		return strings.join('\n');
	}

	public static function parseFile(hxmlFile:String):Hxml {
		if (!FileSystem.exists(hxmlFile))
			throw 'File `${hxmlFile}` doesn\'t exist';

		final hxml = new Hxml(hxmlFile);

		final file = File.read(hxmlFile, false);

		try {
			while (!file.eof()) {
				final line = file.readLine().trim();

				if (line == '')
					continue;

				if (line.charAt(0) != '-') {
					hxml.add(FILE(line));
					continue;
				}

				final first_space_pos = line.indexOf(' ');

				if (first_space_pos != -1) {
					final swtch = line.substr(0, first_space_pos).replace('-', '').trim();
					final value = line.substr(first_space_pos + 1).trim();

					hxml.add(SWITCH(swtch, value));
				} else {
					hxml.add(SWITCH(line, ''));
				}
			}
		} catch (err) {}

		return hxml;
	}

	public final name:String;

	private function new(name:String) {
		this.name = name;
	}
}
