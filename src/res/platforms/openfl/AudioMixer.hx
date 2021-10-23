package res.platforms.openfl;

import res.audio.AudioChannel;
import res.audio.AudioMixerBase;
import res.audio.IAudioBuffer;

class AudioMixer extends AudioMixerBase {
	public function new() {}

	override function createAudioChannel(buffer:IAudioBuffer, ?loop:Bool = false):AudioChannel {
		return new res.platforms.openfl.AudioChannel(cast buffer, loop);
	}
}
