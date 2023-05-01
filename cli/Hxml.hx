package cli;

import cli.types.ResProjectConfig;
import sys.io.File;

function createHaxeArgs(resCli:ResCli, cfg:ResProjectConfig, platform:PlatformId) {
	final result:Array<Array<String>> = [["# This file is generated automatically by the RES CLI tool"]];

	result.push(['-cp', cfg.src.path]);
	result.push(['-main', cfg.src.main]);

	final allDeps = cfg.libs[_all].concat(cfg.libs[platform]);

	for (dep in allDeps)
		result.push(['-lib', dep[0]]);

	result.push(switch (platform) {
		case _all:
			[];
		case hl:
			['--hl', '${cfg.build.path}/hl/hlboot.dat'];
		case js:
			['--js', '${cfg.build.path}/js/${cfg.dist.exeName}.js'];
	});

	return result;
}

function writeHxmlFile(resCli:ResCli, cfg:ResProjectConfig, platform:PlatformId) {
	final fileName = 'res.$platform.hxml';
	final fileContent = createHaxeArgs(resCli, cfg, platform).map(p -> p.join(' ')).join('\n');
	File.saveContent('${Sys.getCwd()}/$fileName', fileContent);
	return fileName;
}
