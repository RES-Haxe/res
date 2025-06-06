package cli;

import Sys.command;
import haxe.io.Path;
import sys.io.File;

using sys.FileSystem;

/**
	Get home directory
**/
function getHomeDir() {
	if (Sys.systemName() == "Windows")
		return Sys.getEnv('USERPROFILE');

	return Sys.getEnv('HOME');
}

/**
	Get temp directory
**/
function getTempDir() {
	if (Sys.systemName() == "Windows")
		return Sys.getEnv('USERPROFILE');

	return '/tmp';
}

/**
	Copy file tree
**/
function copyTree(from:String, to:String, verbose:Bool = false, ?filter:(path:String) -> Bool) {
	if (filter != null && filter(from) == false)
		return;

	if (from.isDirectory()) {
		if (verbose)
			Sys.println('D $from -> $to');
		to.createDirectory();

		for (item in from.readDirectory()) {
			copyTree(Path.join([from, item]), Path.join([to, item]), filter);
		}
	} else {
		if (verbose)
			Sys.println('F $from -> $to');

		File.copy(from, to);
	}
}

/**
	Delete a non-empty directory
**/
function wipeDirectory(dirPath:String) {
	if (!FileSystem.exists(dirPath))
		return;

	if (!FileSystem.isDirectory(dirPath))
		return;

	if (Sys.systemName() == 'Windows')
		command('powershell', ['Remove-Item -Path "$dirPath" -Recurse -Force']);
	else
		command('rm', ['-rf', dirPath]);
}

/**
	Extract archive
**/
function extractArchive(archive:String, dest:String) {
	if (Sys.systemName().toLowerCase() == 'windows' && Path.extension(archive).toLowerCase() == 'zip')
		command('powershell', ['Expand-Archive -Path "$archive" -DestinationPath "$dest"']);
	else
		command('tar', ['-xf', archive, '-C', dest, '--force-local']);
}

/**
	Add ".exe" extension to the filename on Windows
	Don't otherwise
**/
function appExt(name:String)
	return Sys.systemName().toLowerCase() == 'windows' ? '$name.exe' : name;

function relativizePath(basePath:String, path:String):String {
	final normBase = Path.normalize(basePath);
	final normPath = Path.normalize(path);

	if (normBase == normPath)
		return '.';

	final baseParts = normBase.split('/');
	final pathParts = normPath.split('/');

	final result:Array<String> = [];

	while (baseParts[0] == pathParts[0]) {
		baseParts.shift();
		pathParts.shift();
	}

	for (_ in baseParts)
		result.push('..');

	for (part in pathParts)
		result.push(part);

	return result.join('/');
}
