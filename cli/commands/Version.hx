package cli.commands;

import sys.io.File;
import haxe.io.Path;
import cli.CLI.Argument;
import Sys.println;

class Version extends Command {
	public function description():String {
		return "Display the version of the Res CLI tool.";
	}

	public function expectedArgs(resCli):Array<Argument> {
		return [];
	}

	public function run(args:Map<String, String>) {
		final haxelib_file_content = Path.join([resCli.baseDir, 'haxelib.json']);
		try {
			final haxelib_json:{version:String} = haxe.Json.parse(File.getContent(haxelib_file_content));
			println(haxelib_json.version);
		} catch (e:Dynamic) {
			CLI.error('Failed to read haxelib.json file at ${haxelib_file_content}');
			return;
		}
	}
}
