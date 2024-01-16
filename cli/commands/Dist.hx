package cli.commands;

import Sys.println;
import cli.CLI.Argument;
import cli.CLI.error;
import cli.OS.appExt;
import cli.OS.copyTree;
import cli.OS.wipeDirectory;
import cli.commands.Build.buildArgument;
import haxe.io.Path;
import sys.FileSystem.*;

using StringTools;

class Dist extends Command {
	public function description():String
		return 'Prepare a package for distribution';

	public function expectedArgs(resCli):Array<Argument>
		return [buildArgument];

	public function run(args:Map<String, String>) {
		final buildCmd:Build = cast resCli.commands['build'];

		buildCmd.run(args);

		if (!buildCmd.success)
			return;

		final hxml = buildCmd.hxml;

		final cfgName = Path.withoutExtension(hxml.name);

		final distPath = 'dist';

		createDirectory(distPath);

		final hl = hxml.getSwitch('hl');

		if (hl.length > 0) {
			final hlDistPath = Path.join([distPath, cfgName]);
			final hlBuildPath = Path.directory(hl[0]);

			if (exists(hlDistPath)) {
				println('Build directory exists. Nuking it!');
				wipeDirectory(hlDistPath);
			}

			createDirectory(hlDistPath);

			println('Copy runtime files...');
			copyTree(Path.join([resCli.baseDir, 'bin', 'hl', Sys.systemName().toLowerCase()]), hlDistPath,
				(path:String) -> path != 'include' && !path.toLowerCase().endsWith('.lib'));
			wipeDirectory(Path.join([hlDistPath, 'include']));

			final exeName = appExt(Path.join([hlDistPath, 'game']));
			final origExePath = appExt(Path.join([hlDistPath, 'hl']));

			rename(origExePath, exeName);

			if (Sys.systemName().toLowerCase() != 'windows')
				Sys.command('chmod +x $exeName');

			println('Copy bytecode...');
			copyTree(hlBuildPath, hlDistPath);

			println('Done: $hlDistPath');

			return;
		}

		return error("No supported targets found");
	}
}
