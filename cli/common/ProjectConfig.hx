package cli.common;

import cli.CLI.error;
import cli.types.ResProjectConfig;
import haxe.Json;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

using Reflect;

final PROJECT_CONFIG_FILENAME = 'res.json';

function getProjectConfig(resCli:ResCli):ResProjectConfig {
	final cfgFilePath = Path.join([resCli.workingDir, PROJECT_CONFIG_FILENAME]);

	if (!FileSystem.exists(cfgFilePath))
		error('${PROJECT_CONFIG_FILENAME} is missing in ${resCli.workingDir}');

	try {
		final parsedData:Dynamic<String> = Json.parse(File.getContent(cfgFilePath));
		final result:ResProjectConfig = {
			name: parsedData.field('name'),
			version: parsedData.field('version'),
			src: {
				path: parsedData.field('src').field('path'),
				main: parsedData.field('src').field('main')
			},
			build: {
				path: parsedData.field('build').field('path')
			},
			dist: {
				path: parsedData.field('dist').field('path'),
				exeName: parsedData.field('dist').field('exeName'),
			},
			libs: [_all => [], js => [], hl => []]
		};

		for (platform in parsedData.field('libs').fields())
			result.libs[cast platform] = parsedData.field('libs').field(platform);

		return result;
	} catch (err) {
		error('Config file parsing error: ${err}');
		return null;
	}
}
