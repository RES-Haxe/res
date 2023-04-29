package cli.commands;

import Sys.print;
import Sys.println;
import cli.CLI.Argument;
import cli.CLI.error;
import cli.Network.downloadFile;
import cli.OS.extractArchive;
import cli.ResCli.RUNTIME_DIR;
import cli.common.CoreDeps.getCoreDeps;
import cli.common.ProjectConfig.getProjectConfig;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;

using Reflect;
using StringTools;
using haxe.io.Path;

class Bootstrap extends Command {
	public function description():String
		return 'Install all the dependencies for the project';

	public function expectedArgs(resCli):Array<Argument>
		return [];

	function downloadRuntime() {
		final runtimeDir = Path.join([resCli.workingDir, RUNTIME_DIR]);

		if (FileSystem.exists(runtimeDir))
			return;

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

		FileSystem.createDirectory(runtimeDir);

		print('Download hashlink...');
		final hl_url = 'https://github.com/HaxeFoundation/hashlink/releases/download/latest/hashlink-2206f8c-${platform}';
		final hl_archive = Path.join([resCli.workingDir, hl_url.withoutDirectory()]);

		downloadFile(hl_url, hl_archive);
		extractArchive(hl_archive, runtimeDir);
		for (dir in FileSystem.readDirectory(runtimeDir)) {
			if (dir.startsWith('hashlink'))
				FileSystem.rename(Path.join([runtimeDir, dir]), Path.join([runtimeDir, 'hashlink']));
		}
		FileSystem.deleteFile(hl_archive);
	}

	public function run(args:Map<String, String>) {
		final config = getProjectConfig(resCli);

		final dependencies = getCoreDeps(resCli);

		for (platformId => deps in config.libs) {
			for (item in deps)
				dependencies[cast platformId].push(item);
		}

		if (resCli.tools.haxelib.run(['newrepo']) != 0)
			error('Filed to create a local repo');

		for (platformId => deps in dependencies) {
			for (dep in deps) {
				var retries = 1;
				while (true) {
					var args = ['install', dep[0]];
					var src = 'haxelib';

					if (dep.length == 3) {
						args = [dep[1], dep[0], dep[2]];
						src = dep[1];
					}

					print('install [$platformId]: ${dep[0]} (${src})');

					final output:Array<String> = [];

					final exitCode = resCli.tools.haxelib.run(args, (s) -> output.push(s), (s) -> output.push(s));

					if (exitCode != 0) {
						final errorMessage = output.pop();

						if (errorMessage.toLowerCase().indexOf('certificate verification failed') != -1) {
							if (retries == 0)
								return error('Certificate error detected again. Apperently the fix did not work...');

							println('Certificate error detected. Attempting to fix it...');
							Sys.command('curl https://lib.haxe.org/p/haxelib/4.0.3/download/ -o -');
							println('Done. Try again...');
							retries--;
						} else {
							println(' Error');
							println('  ${output.pop()}');
							break;
						}
					} else {
						println(' OK');
						break;
					}
				}
			}
		}

		if (resCli.tools.npm.available) {
			resCli.tools.npm.run(['init', '-y', '--name=${config.name}', '--yes'], (s) -> {}, (s) -> {}, true);
			resCli.tools.npm.run(['install', '-D', 'http-server', 'nodemon', 'concurrently'], (s) -> {}, (s) -> {}, true);

			final pkg = Json.parse(File.getContent('./package.json'));

			Reflect.setField(pkg, 'scripts', {
				serve: 'http-server build/js -o',
				start: 'concurrently "npm run watch" "npm run serve"',
				watch: 'nodemon --watch src/**/*.* --exec res build js'
			});

			File.saveContent('./package.json', Json.stringify(pkg, null, '  '));
		}

		downloadRuntime();
	}
}
