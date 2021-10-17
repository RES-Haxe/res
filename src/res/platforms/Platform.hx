package res.platforms;

import res.audio.IAudioBuffer;
import res.audio.IAudioMixer;
import res.audio.IAudioStream;

class Platform {
	public var name(get, never):String;

	function get_name():String
		return 'Unknown';

	public var frameBuffer(get, never):IFrameBuffer;

	function get_frameBuffer():IFrameBuffer
		throw 'Not implemented';

	public function connect(res:RES)
		throw 'Not implemented';

	public function createAudioBuffer(audioStream:IAudioStream):IAudioBuffer
		throw 'Not implemented';

	public function createAudioMixer():IAudioMixer
		throw 'Not implemented';
}
