package cli.common;

import cli.CLI.error;
import cli.ResCli.PROJECT_CONFIG_FILENAME;
import cli.types.ResProjectConfig;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;

using Reflect;

function getProjectConfig(resCli:ResCli):ResProjectConfig {
	if (!FileSystem.exists(PROJECT_CONFIG_FILENAME))
		error('${PROJECT_CONFIG_FILENAME} is missing in ${Sys.getCwd()}');

	try {
		final parsedData:Dynamic<String> = Json.parse(File.getContent(PROJECT_CONFIG_FILENAME));
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
