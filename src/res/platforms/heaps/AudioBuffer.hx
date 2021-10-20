package res.platforms.heaps;

import hxd.res.Sound;
import res.audio.IAudioBuffer;
import res.audio.IAudioStream;

class AudioBuffer implements IAudioBuffer {
	public final numChannel:Int;

	public final numSamples:Int;

	public final sampleRate:Int;

	public function new(audioStream:IAudioStream) {
		numChannel = audioStream.numChannels;
		numSamples = audioStream.numSamples;
		sampleRate = audioStream.sampleRate;
	}
}
