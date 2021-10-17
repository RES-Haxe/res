package res.platforms.js;

import js.html.audio.AudioContext;
import res.audio.AudioChannel;
import res.audio.AudioMixerBase;
import res.audio.IAudioBuffer;

class Html5AudioMixer extends AudioMixerBase {
	final _ctx:AudioContext;

	public function new(ctx:AudioContext) {
		_ctx = ctx;
	}

	override public function createAudioChannel(buffer:IAudioBuffer, ?loop:Bool):AudioChannel {
		return new Html5AudioChannel(_ctx, cast buffer, loop);
	}
}
