package cli;

import haxe.io.Path;
import sys.FileSystem;

using Lambda;
using StringTools;

function getTemplateList(resCli:ResCli):Array<String> {
	return FileSystem.readDirectory(Path.join([resCli.baseDir, 'templates'])).filter(s -> !s.startsWith('_'));
}
