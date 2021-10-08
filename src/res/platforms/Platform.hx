package res.platforms;

import res.types.RESConfig;

class Platform {
	public var name(get, never):String;

	function get_name():String
		return 'Unknown';

	public var frameBuffer(get, never):IFrameBuffer;

	function get_frameBuffer():IFrameBuffer
		throw 'Not implemented';

	public function connect(res:RES)
		throw 'Not implemented';

	public function playAudio(id:String)
		throw 'Not implemented';
}
