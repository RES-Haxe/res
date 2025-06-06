package cli.commands;

import Sys.command;
import Sys.println;
import cli.CLI.Argument;
import cli.CLI.ask_yn;
import cli.Network.downloadFile;
import cli.OS.getTempDir;
import cli.OS.wipeDirectory;
import sys.FileSystem.createDirectory;
import sys.FileSystem.exists;
import sys.io.File;

using StringTools;
using haxe.io.Path;

final HL_VERSION = '1.15';
final sysname = Sys.systemName().toLowerCase();

final hl_url = [
	'windows' => 'https://github.com/RES-Haxe/res/releases/download/hashlink-1.15/hashlink-1.15-win64.zip',
	'linux' => 'https://github.com/RES-Haxe/res/releases/download/hashlink-1.15/hashlink-1.15-linux64.tar.gz',
];

function downloadHashlink(resCli:ResCli):Void {
	final hlDir = Path.join([resCli.resHomeDir, 'bin', 'runtime', 'hl', HL_VERSION]);
	final tmpDir = getTempDir();

	final hlFile = Path.join([tmpDir, 'hashlink.zip']);

	downloadFile(hl_url[sysname], hlFile);

	command('tar', ['-xzf', hlFile, '--strip-components=1', '-C', hlDir]);
}

function installCommand(resCli:ResCli) {
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

class Setup extends Command {
	public function description():String
		return 'Setup the evirnment to use the engine';

	public function expectedArgs(resCli:ResCli):Array<Argument>
		return [];

	public function run(args:Map<String, String>) {
		println('Setting up the environment for RES...');

		final resHome = resCli.resHomeDir;

		if (exists(resHome)) {
			println('WARNING: ${resHome} already exists.');
			println('         This directory will be used to store RES configuration and runtimes');
		} else {
			println('Create RES home directory: $resHome');
			createDirectory(resHome);
		}
		final binDir = Path.join([resHome, 'bin']);
		if (exists(binDir)) {
			println('WARNING: ${binDir} already exists.');
			println('         This directory will be used to store required binaries for RES');
		} else {
			println('Create RES bin directory: $binDir');
			createDirectory(binDir);
		}
		if (hl_url.exists(sysname)) {
			final hlDir = Path.join([binDir, 'runtime', 'hl', HL_VERSION]);

			var needHl = true;

			if (exists(hlDir)) {
				println('WARNING: ${hlDir} already exists.');
				needHl = ask_yn('Do you want to reinstall HashLink runtime?');

				if (needHl) {
					println('Removing existing HashLink runtime directory: $hlDir');
					try {
						wipeDirectory(hlDir);
					} catch (err) {
						println('Failed to remove existing HashLink runtime directory: $err');
						return;
					}
				}
			} else {
				println('Create HashLink runtime directory: $hlDir');
			}

			if (needHl) {
				createDirectory(hlDir);
				downloadHashlink(resCli);
			}
		} else {
			println('HashLink runtime is not available for your platform: $sysname');
			println('Please install HashLink runtime manually from https://hashlink.haxe.org/download.html');
		}
		if (ask_yn('Do you want to install the "res" command?'))
			installCommand(resCli);
	}
}
