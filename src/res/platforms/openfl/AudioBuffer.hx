package res.platforms.openfl;

import openfl.media.Sound;
import openfl.utils.ByteArray;
import res.audio.IAudioBuffer;
import res.audio.IAudioStream;

class AudioBuffer implements IAudioBuffer {
	public final numChannel:Int;
	public final numSamples:Int;
	public final sampleRate:Int;
	public final sound:Sound;

	public function new(audioStream:IAudioStream) {
		numChannel = audioStream.numChannels;
		numSamples = audioStream.numSamples;
		sampleRate = audioStream.sampleRate;

		if (numChannel > 2)
			throw 'Only mono and stereo are supported';

		final byteArray = new ByteArray(numSamples * numChannel * 2);

		for (_ => sample in audioStream)
			for (amp in sample)
				byteArray.writeShort(Std.int(amp * 32767));

		byteArray.position = 0;

		sound = new Sound();
		sound.loadPCMFromByteArray(byteArray, numSamples, "short", numSamples == 2, sampleRate);
	}
}
