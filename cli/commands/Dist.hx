package cli.commands;

import Sys.println;
import cli.CLI.Argument;
import cli.CLI.error;
import cli.OS.appExt;
import cli.OS.copyTree;
import cli.OS.wipeDirectory;
import cli.commands.common.PlatformArg.platformArg;
import cli.common.ProjectConfig.getProjectConfig;
import haxe.io.Path;
import sys.FileSystem.*;

using StringTools;

class Dist extends Command {
	public function description():String
		return 'Prepare a package for distribution';

	public function expectedArgs(resCli):Array<Argument>
		return [platformArg];

	public function run(args:Map<String, String>) {
		resCli.commands['build'].run(args);

		final projectConfig = getProjectConfig(resCli);

		final distPath = 'dist';

		createDirectory(distPath);

		switch (args['platform']) {
			case 'hl':
				final hlDistPath = Path.join([distPath, 'hl']);
				final hlBuildPath = Path.join([projectConfig.build.path, 'hl']);

				if (exists(hlDistPath)) {
					println('Build directory exists. Nuking it!');
					wipeDirectory(hlDistPath);
				}

				createDirectory(hlDistPath);

				println('Copy runtime files...');
				copyTree(Path.join([resCli.runtimeDir, 'hashlink']), hlDistPath, (path:String) -> path != 'include' && !path.toLowerCase().endsWith('.lib'));
				wipeDirectory(Path.join([hlDistPath, 'include']));

				final exeName = appExt(Path.join([hlDistPath, projectConfig.dist.exeName]));
				final origExePath = appExt(Path.join([hlDistPath, 'hl']));

				rename(origExePath, exeName);

				if (Sys.systemName().toLowerCase() != 'windows')
					Sys.command('chmod +x $exeName');

				println('Copy bytecode...');
				copyTree(hlBuildPath, hlDistPath);

				println('Done: $hlDistPath');
			case 'js':
				println('Not implemented yet');
			default:
				return error('Unknown platform ${args['platform']}');
		}
	}
}
