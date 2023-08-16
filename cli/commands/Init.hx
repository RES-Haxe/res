package cli.commands;

import Sys.println;
import cli.CLI.Argument;
import cli.CLI.ask;
import cli.CLI.error;
import cli.Hxml.writeHxmlFile;
import cli.OS.copyTree;
import cli.OS.relativizePath;
import cli.ResCli.PROJECT_CONFIG_FILENAME;
import cli.Templates.getTemplateList;
import cli.common.CoreDeps.getCoreDeps;
import cli.types.ResProjectConfig;
import haxe.Json;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

class Init extends Command {
	final templateList:Array<String>;

	override public function new(resCli:ResCli) {
		super(resCli);

		templateList = getTemplateList(resCli);
	}

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
				name: 'template',
				type: ENUM(templateList),
				desc: 'The name of a template to use to initialize the project. Available templates: ${templateList.join(', ')}',
				defaultValue: (?prev) -> 'default',
				requred: false,
				interactive: false,
				example: 'default'
			}
		];

	public function run(args:Map<String, String>) {
		final dir = Path.normalize(Path.join([Sys.getCwd(), args['name']]));

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

		if (templateList.indexOf(template) == -1)
			return error('Template <$template> not found');

		final currentDir = Sys.getCwd();

		Sys.setCwd(dir);

		println('Initializing a RES project in: $dir...');

		try {
			copyTree(Path.join([resCli.baseDir, 'templates', '_common']), dir);
			copyTree(Path.join([resCli.baseDir, 'templates', template]), dir);

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
				libs: getCoreDeps(resCli),
				defs: [_all => [['no-deprecation-warnings']]] // Need to remove this one day
			};

			for (platform in [hl, js])
				writeHxmlFile(resCli, projectConfig, platform);

			File.saveContent(Path.join([dir, PROJECT_CONFIG_FILENAME]), Json.stringify(projectConfig, null, '  '));

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
