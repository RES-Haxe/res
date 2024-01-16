package cli.commands;

import Sys.command;
import Sys.println;
import cli.CLI.Argument;
import cli.CLI.ask_yn;
import sys.FileSystem.createDirectory;
import sys.FileSystem.exists;
import sys.io.File;

using StringTools;
using haxe.io.Path;

class Setup extends Command {
	public function description():String
		return 'Setup the evirnment to use the engine';

	public function expectedArgs(resCli:ResCli):Array<Argument>
		return [];

	public function run(args:Map<String, String>) {
		final resHome = resCli.resHomeDir;

		if (exists(resHome)) {
			println('WARNING: ${resHome} already exists.');
			println('         This directory will be used to store RES configuration and runtimes');
		} else {
			println('Create RES home directory: $resHome');
			createDirectory(resHome);
		}

		final installCmd = ask_yn('Do you want to install the "res" command?');

		if (!installCmd)
			return;

		final sysname = Sys.systemName().toLowerCase();

		if (sysname == 'windows') {
			function failure() {
				println('Unable to install the global command.');
				println('Please add the following path to your PATH environmen variable:');
				println(Path.join([resCli.baseDir, 'bin']));
			}

			var haxePath = Sys.getEnv('HAXEPATH');

			if (haxePath == null) {
				haxePath = 'C:\\HaxeToolkit\\haxe';

				if (!exists(haxePath)) {
					failure();
					return;
				}
			}

			final scriptSrc = Path.join([resCli.baseDir, 'bin', 'res.bat']);
			final scriptPath = Path.join([haxePath, 'res.bat']);

			try {
				File.copy(scriptSrc, scriptPath);
				println('Script is created at: $scriptPath');
			} catch (err) {
				println(err.message);
				failure();
			}
		} else {
			final scriptPath = '/usr/local/bin/res';
			final scriptSrc = Path.join([resCli.baseDir, 'bin', 'res']);

			command("sudo", ['cp', scriptSrc, scriptPath]);
			command("sudo", ['chmod', '+x', scriptPath]);
			println('Script is created at: $scriptPath');
		}
	}
}
