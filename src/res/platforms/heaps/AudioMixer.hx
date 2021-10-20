package res.platforms.heaps;

import res.audio.IAudioBuffer;
import res.audio.AudioMixerBase;

class AudioMixer extends AudioMixerBase {
	public function new() {}

	override function createAudioChannel(buffer:IAudioBuffer, ?loop:Bool):res.audio.AudioChannel {
		return new AudioChannel(cast buffer, loop);
	}
}
