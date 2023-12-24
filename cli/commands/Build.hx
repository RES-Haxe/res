package cli.commands;

import Sys.command;
import Sys.println;
import cli.CLI.Argument;
import cli.CLI.error;
import cli.Command;
import cli.common.Hxml;
import sys.FileSystem;

using StringTools;

final buildArgument:Argument = {
	name: 'config',
	desc: 'Configuration to build. The name of a .hxml file without the extention',
	requred: false,
	defaultValue: (?prev) -> null,
	type: STRING,
	interactive: true,
	example: 'hl'
};

class Build extends Command {
	public var hxml:Hxml;
	public var success:Bool = false;

	public function description()
		return "Build the project";

	public function expectedArgs(resCli):Array<Argument>
		return [
			buildArgument
		];

	public function run(args:Map<String, String>) {
		var hxmlFile:String = '';

		if (args['config'] == null) {
			final listFiles = FileSystem.readDirectory('.').filter(f -> f.toLowerCase().endsWith('.hxml'));

			listFiles.sort((a, b) -> a < b ? -1 : 1);

			if (listFiles.length == 0)
				return error('Config name is not specified and no hxml files found in the directory');

			if (listFiles.length == 1)
				hxmlFile = listFiles[0];
			else {
				println('Ambiguous configuration file:');
				for (file in listFiles) {
					println(' - ${file}');
				}

				var hlFound = false;
				for (file in listFiles) {
					if (Hxml.parseFile(file).getSwitch('hl').length > 0) {
						println('Picking the first configuration file with HL target: $file');
						hlFound = true;
						hxmlFile = file;
						break;
					}
				}

				if (!hlFound) {
					println('Picking the first file in list: ${listFiles[0]}');
					hxmlFile = listFiles[0];
				}
			}
		} else
			hxmlFile = '${args['config']}.hxml';

		try {
			hxml = Hxml.parseFile(hxmlFile);
		} catch (err) {
			return error('$err');
		}

		println('Build ${hxmlFile}');

		final exitCode = command('haxe', [hxmlFile]);

		println('');

		if (exitCode != 0)
			return error('Build failed');

		success = true;
	}
}
