package cli;

using haxe.io.Path;

function downloadFile(url:String, ?to:String) {
	final fileName = url.withoutDirectory();

	if (to == null)
		to = fileName;

	Sys.println('Downloading $url to $fileName...');
	Sys.command('curl', [url, '-L', '-o', to]);
	Sys.println(' Done.');
}
