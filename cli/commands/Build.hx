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

			if (listFiles.length == 0)
				return error('Config name is not specified and no hxml files found in the directory');

			if (listFiles.length == 1)
				hxmlFile = listFiles[0];
			else
				return error('More than one hxml file found. Please provide one of those:\n${listFiles.map(s -> '- ${s.substr(0, -5)}').join('\n')}');
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
