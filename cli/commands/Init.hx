package cli.commands;

import Sys.println;
import cli.CLI.Argument;
import cli.CLI.ask;
import cli.CLI.error;
import cli.Hxml.writeHxmlFile;
import cli.OS.copyTree;
import cli.OS.relativizePath;
import cli.ResCli.CLI_CONFIG_FILENAME;
import cli.ResCli.PROJECT_CONFIG_FILENAME;
import cli.common.CliConfig;
import cli.types.ResProjectConfig;
import haxe.Json;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

function templateList(resCli:ResCli)
	return FileSystem.readDirectory(Path.join([resCli.baseDir, 'templates']));

class Init extends Command {
	public function description():String
		return 'Initialize a RES project';

	public function expectedArgs(resCli:ResCli):Array<Argument>
		return [
			{
				name: 'name',
				type: STRING,
				desc: 'Project name',
				defaultValue: null,
				requred: true,
				interactive: true,
				example: 'My Game'
			},
			{
				name: 'dir',
				type: STRING,
				desc: 'Directory to initialize the project in. Use "." to initialize the project in the current directory',
				defaultValue: (?prev) -> Path.join([Sys.getCwd(), prev != null ? prev['name'] : '{name}']),
				requred: false,
				interactive: false,
				example: './my_game'
			},
			{
				name: 'template',
				type: ENUM(templateList(resCli)),
				desc: 'The name of a template to use to initialize the project. Available templates: ${templateList(resCli).join(', ')}',
				defaultValue: (?prev) -> 'default',
				requred: false,
				interactive: false,
				example: 'default'
			}
		];

	public function run(args:Map<String, String>) {
		final dir = Path.normalize(Path.isAbsolute(args['dir']) ? args['dir'] : Path.join([args['dir']]));

		if (!FileSystem.exists(dir)) {
			try {
				FileSystem.createDirectory(dir);
			} catch (error) {
				return CLI.error('Failed to create direcotry $dir: ${error.message}');
			}
		}

		if (FileSystem.readDirectory(dir).length > 0) {
			if (ask({
				desc: 'Directory $dir is not empty. Are you sure you want to proceed?',
				type: BOOL,
				requred: true,
				interactive: true,
				defaultValue: (?prev) -> 'false'
			}) == 'false')
				Sys.exit(0);
		}

		final template = args['template'];

		final templatePath = Path.join([resCli.baseDir, 'templates', template]);

		if (!FileSystem.exists(templatePath))
			return error('Template <$template> not found');

		final currentDir = Sys.getCwd();

		Sys.setCwd(dir);

		println('Initializing a RES project in: $dir...');

		try {
			copyTree(templatePath, dir);

			final projectConfig:ResProjectConfig = {
				name: args['name'],
				version: '0.1.0',
				src: {
					path: './src',
					main: 'Main'
				},
				build: {
					path: './build'
				},
				dist: {
					path: './dist',
					exeName: 'game'
				},
				libs: [_all => [], hl => [], js => []]
			};

			for (platform in [hl, js])
				writeHxmlFile(resCli, projectConfig, platform);

			File.saveContent(Path.join([dir, PROJECT_CONFIG_FILENAME]), Json.stringify(projectConfig, null, '  '));

			final cliConfig:CliConfig = {
				tools: {}
			};

			File.saveContent(CLI_CONFIG_FILENAME, Json.stringify(cliConfig, null, '  '));

			resCli.commands['bootstrap'].run([]);

			println('Done! Now you can test the newly created project by running:');
			if (currentDir != dir)
				println('  cd ${relativizePath(currentDir, dir)}');
			println('  res run');
		} catch (error) {
			return CLI.error('ERROR: ${error.message}');
		}
	}
}
