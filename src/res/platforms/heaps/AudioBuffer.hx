package res.platforms.heaps;

import haxe.io.Bytes;
import haxe.io.BytesOutput;
import hxd.res.Sound;
import hxd.snd.Data;
import res.audio.IAudioBuffer;
import res.audio.IAudioStream;

class HeapsAudioData extends Data {
	var stream:IAudioStream;

	var rawPCM:Bytes;

	public function new(stream:IAudioStream) {
		this.stream = stream;

		channels = stream.numChannels;
		samples = stream.numSamples;
		samplingRate = stream.sampleRate;
		sampleFormat = F32;

		final bo = new BytesOutput();

		for (n => sample in stream) {
			for (nChannel => amp in sample) {
				bo.writeFloat(amp);
			}
		}

		rawPCM = bo.getBytes();
	}

	override function decodeBuffer(out:Bytes, outPos:Int, sampleStart:Int, sampleCount:Int) {
		out.blit(outPos, rawPCM, sampleStart * 4, sampleCount * 4);
	}
}

class AudioBuffer implements IAudioBuffer extends Sound {
	public final numChannel:Int;

	public final numSamples:Int;

	public final sampleRate:Int;

	var stream:IAudioStream;

	override function getData():Data {
		return new HeapsAudioData(stream);
	}

	public function new(audioStream:IAudioStream) {
		super(null);

		stream = audioStream;

		numChannel = audioStream.numChannels;
		numSamples = audioStream.numSamples;
		sampleRate = audioStream.sampleRate;
	}
}
