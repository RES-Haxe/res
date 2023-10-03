package cli.commands;

import Sys.print;
import Sys.println;
import cli.CLI.Argument;
import cli.CLI.ask_yn;
import cli.CLI.error;
import cli.common.Hxml;
import sys.FileSystem;
import sys.io.Process;

using Reflect;
using StringTools;
using haxe.io.Path;

final GIT_DEPS = ['res' => 'https://github.com/RES-Haxe/res.git', 'res-html5' =>
	'https://github.com/RES-Haxe/res-html5.git', 'res-hl' => 'https://github.com/RES-Haxe/res-hl.git'];

class Bootstrap extends Command {
	public function description():String
		return 'Install all the dependencies for the project';

	public function expectedArgs(resCli):Array<Argument>
		return [];

	public function run(args:Map<String, String>) {
		if (!FileSystem.exists('.haxelib')) {
			if (ask_yn("Would you like to create an isolated Haxelib repository?", false)) {
				resCli.tools.haxelib.run(['newrepo'], s -> Sys.println(s));
			}
		}

		final hxmls = FileSystem.readDirectory('.').filter(f -> f.toLowerCase().endsWith('.hxml')).map(f -> Hxml.parseFile(f));

		final required:Array<String> = [];

		for (hxml in hxmls) {
			for (lib in hxml.getSwitch('lib')) {
				if (required.indexOf(lib) == -1)
					required.push(lib);
			}
		}

		final installed:Array<String> = [];

		final list = new Process('haxelib', ['list']).stdout.readAll().toString().split('\n');

		for (lib in list) {
			final parsed = lib.split(':');
			installed.push(parsed[0]);
		}

		for (lib in required) {
			if (installed.indexOf(lib) != -1)
				continue;

			var retries = 1;
			while (true) {
				var args = ['install', lib];
				var src = 'haxelib';

				if (GIT_DEPS.exists(lib)) {
					src = 'git';
					args = ['git', lib, GIT_DEPS[lib]];
				}

				print('Install `$lib` (${src})');

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
}
