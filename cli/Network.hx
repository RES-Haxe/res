package cli;

using haxe.io.Path;

function downloadFile(url:String, to:String) {
	Sys.println('Downloading $url to $to...');
	Sys.command('curl', [url, '-L', '-o', to]);
	Sys.println(' Done.');
}
