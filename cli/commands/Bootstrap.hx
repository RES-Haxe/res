package cli.commands;

import Sys.print;
import Sys.println;
import cli.CLI.Argument;
import cli.CLI.error;
import cli.common.ProjectConfig.getProjectConfig;
import haxe.Json;
import sys.io.File;
import sys.io.Process;

using Reflect;
using StringTools;
using haxe.io.Path;

class Bootstrap extends Command {
	public function description():String
		return 'Install all the dependencies for the project';

	public function expectedArgs(resCli):Array<Argument>
		return [];

	public function run(args:Map<String, String>) {
		final config = getProjectConfig(resCli);
		final installed:Array<String> = [];

		final list = new Process('haxelib', ['list']).stdout.readAll().toString().split('\n');

		for (lib in list) {
			final parsed = lib.split(':');
			installed.push(parsed[0]);
		}

		for (platformId => deps in config.libs) {
			for (dep in deps) {
				if (installed.indexOf(dep[0]) != -1)
					continue;

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
	}
}
