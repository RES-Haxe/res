package cli.commands;

import Sys.command;
import Sys.println;
import cli.CLI.Argument;
import cli.CLI.ask_yn;
import cli.Network.downloadFile;
import cli.OS.extractArchive;
import cli.OS.getTempDir;
import sys.FileSystem.createDirectory;
import sys.FileSystem.deleteFile;
import sys.FileSystem.exists;
import sys.FileSystem.readDirectory;
import sys.FileSystem.rename;
import sys.io.File;

using StringTools;
using haxe.io.Path;

class Setup extends Command {
	public function description():String
		return 'Setup the evirnment to use the engine';

	public function expectedArgs(resCli:ResCli):Array<Argument>
		return [];

	function downloadRuntime(runtimeDir:String) {
		final sys_name = Sys.systemName().toLowerCase();

		final platform:String = switch sys_name {
			case 'windows':
				'win64.zip';
			case 'linux':
				'linux-amd64.tar.gz';
			case 'mac':
				'darwin.tar.gz';
			default: throw 'Unsuppored platform';
		}

		final hl_url = 'https://github.com/HaxeFoundation/hashlink/releases/download/latest/hashlink-2206f8c-${platform}';
		final hl_archive = hl_url.withoutDirectory();
		final local_file = Path.join([getTempDir(), hl_archive]);

		println('Download HashLink VM');

		downloadFile(hl_url, local_file);
		extractArchive(local_file, runtimeDir);

		// Rename whatever comes from the archive to "hashlink"
		for (dir in readDirectory(runtimeDir)) {
			if (dir.startsWith('hashlink'))
				rename(Path.join([runtimeDir, dir]), Path.join([runtimeDir, 'hashlink']));
		}

		deleteFile(local_file);
	}

	public function run(args:Map<String, String>) {
		final resHome = resCli.resHomeDir;

		if (exists(resHome)) {
			println('WARNING: ${resHome} already exists.');
			println('         This directory will be used to store RES configuration and runtimes');
		} else {
			println('Create RES home directory: $resHome');
			createDirectory(resHome);
		}

		final runtimeDir = Path.join([resHome, 'runtime']);

		if (!exists(runtimeDir)) {
			createDirectory(runtimeDir);
			downloadRuntime(runtimeDir);
		} else {
			if (ask_yn("Runtime directory isn't empty. Do you want to re-download the runtime?")) {
				downloadRuntime(runtimeDir);
			};
		}

		final installCmd = ask_yn('Do you want to install the "res" command?');

		if (!installCmd)
			return;

		final sysname = Sys.systemName().toLowerCase();

		if (sysname == 'windows') {
			function failure() {
				println('Unable to install the global command.');
				println('Please add the following path to your PATH environmen variable:');
				println(runtimeDir);
			}

			var haxePath = Sys.getEnv('HAXEPATH');

			if (haxePath == null) {
				haxePath = 'C:\\HaxeToolkit\\haxe';

				if (!exists(haxePath)) {
					failure();
					return;
				}
			}
			final scriptSrc = Path.join([resCli.baseDir, 'extra', 'res.bat']);
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
			final scriptSrc = Path.join([resCli.baseDir, 'extra', 'res']);

			command("sudo", ['cp', scriptSrc, scriptPath]);
			command("sudo", ['chmod', '+x', scriptPath]);
			println('Script is created at: $scriptPath');
		}
	}
}
