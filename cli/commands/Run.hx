package cli.commands;

import Sys.command;
import Sys.println;
import cli.CLI.ask_yn;
import cli.CLI.error;
import cli.Command;
import cli.commands.Build.buildArgument;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class Run extends Command {
	public function description()
		return "Run the project";

	public function expectedArgs(resCli)
		return [
			buildArgument
		];

	function run(args:Map<String, String>) {
		final buildCmd:Build = cast resCli.commands['build'];

		buildCmd.run(args);

		if (!buildCmd.success)
			return;

		final hxml = buildCmd.hxml;

		println('Run ${hxml.name}');

		final trgHl = hxml.getSwitch('hl');

		if (trgHl.length != 0) {
			if (!resCli.tools.hl.available)
				return error('${resCli.tools.hl.name} is not available');

			println('HashLink target');

			final exitCode = command('hl', [trgHl[0]]);

			if (exitCode != 0)
				return error('Run failed');

			return;
		}

		final trgJs = hxml.getSwitch('js');

		if (trgJs.length != 0) {
			if (!resCli.tools.node.available)
				return error('Node.JS is required to run the `js` target');

			println('JavaScript (Browser) target');

			if (!FileSystem.exists('package.json')) {
				if (!ask_yn('package.json not found.\nWould you like to initialize a Node.js project?', false))
					return;

				resCli.tools.npm.run(['init', '-y']);
				resCli.tools.npm.run(['install', '-D', 'http-server']);
			}

			if (!FileSystem.exists('node_modules')) {
				println('`node_modules` directory not found.');
			}

			final buildDir = Path.directory(trgJs[0]);

			final htmlFile = Path.join([buildDir, 'index.html']);

			if (!FileSystem.exists(htmlFile)) {
				final htmlContent = File.getContent(Path.join([resCli.baseDir, 'cli/assets/index.html']))
					.replace('%%JS_FILE%%', Path.withoutDirectory(trgJs[0]));
				File.saveContent(htmlFile, htmlContent);
			}

			command('npx', ['http-server', buildDir, '-o']);

			return;
		}

		return error('No supported target found');
	}
}
