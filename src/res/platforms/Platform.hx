package res.platforms;

class Platform {
	public final pixelFormat:PixelFormat;
	public final name:String;

	public function connect(res:RES)
		throw 'Not implemented';

	public function render(res:RES)
		throw 'Not implemented';

	public function playAudio(id:String)
		throw 'Not implemented';

	public function new(name:String, pixelFormat:PixelFormat) {
		this.name = name;
		this.pixelFormat = pixelFormat;
	}
}
