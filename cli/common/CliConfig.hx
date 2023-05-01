package cli.common;

import cli.CLI.error;
import cli.OS.getHomeDir;
import cli.ResCli.CLI_CONFIG_FILENAME;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;

using haxe.io.Path;

typedef CliConfig = {
	tools:{
		?haxe:String, ?haxelib:String, ?hl:String, ?node:String, ?npm:String, ?neko:String
	}
};

function getCliConfig(resCli:ResCli):CliConfig {
	final cfg_file_path:Array<String> = [];

	// Current directory
	cfg_file_path.push(Sys.getCwd());

	// RES home directory
	cfg_file_path.push(resCli.resHomeDir);

	// ~/.config/res
	cfg_file_path.push(Path.join([getHomeDir(), '.config', 'res']));

	// ~/.config
	cfg_file_path.push(Path.join([getHomeDir(), '.config']));

	if (Sys.systemName() != "Windows")
		cfg_file_path.push('/etc/res-cli');

	// RES base directory (where the RES code/haxelib is)
	cfg_file_path.push(resCli.baseDir);

	for (path in cfg_file_path) {
		final cfg_filename = Path.join([path, CLI_CONFIG_FILENAME]);

		if (FileSystem.exists(cfg_filename)) {
			try {
				final config:CliConfig = Json.parse(File.getContent(cfg_filename));
				return config;
			} catch (err) {
				error('Failed to parse config file ($cfg_filename): ${err.message}');
			}
			break;
		}
	}

	return {tools: {}};
}
