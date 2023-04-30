package cli.commands;

import Sys.println;
import cli.CLI.Argument;
import cli.CLI.error;
import cli.OS.appExt;
import cli.OS.copyTree;
import cli.OS.wipeDirectory;
import cli.ResCli.RUNTIME_DIR;
import cli.commands.common.PlatformArg.platformArg;
import cli.common.ProjectConfig.getProjectConfig;
import haxe.io.Path;
import sys.FileSystem.*;

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
				final hlBuildPath = projectConfig.build.path;

				if (exists(hlDistPath))
					wipeDirectory(hlDistPath);

				createDirectory(hlDistPath);

				println('Copy runtime files...');
				copyTree(Path.join([RUNTIME_DIR, 'hashlink']), hlDistPath);
				wipeDirectory(Path.join([hlDistPath, 'include']));

				final exeName = appExt(Path.join([hlDistPath, projectConfig.dist.exeName]));
				final origExePath = appExt(Path.join([hlDistPath, 'hl']));

				rename(origExePath, exeName);

				if (Sys.systemName().toLowerCase() != 'windows')
					Sys.command('chmod +x $exeName');

				println('Copy bytecode');
				copyTree(hlBuildPath, hlDistPath);

				println('Done: $hlDistPath');
			case 'js':
				println('Not implemented yet');
			default:
				return error('Unknown platform ${args['platform']}');
		}
	}
}
