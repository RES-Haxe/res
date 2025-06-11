import res.CRT;
import res.Palette;
import res.RES;
import res.audio.AudioChannel;
import res.audio.AudioMixer;
import res.audio.IAudioBuffer;
import res.audio.IAudioStream;
import res.bios.BIOS;
import res.storage.Storage;

class DummyCRT extends CRT {
	public function new() {
		super([R, G, B, A]);
	}

	public function beam(x:Int, y:Int, index:Int, palette:Palette) {}
}

class DummyStorage extends Storage {
	public function new() {
		super();
	}
}

class DummyAudioBuffer implements IAudioBuffer {
	public final numChannel:Int;
	public final numSamples:Int;
	public final sampleRate:Int;

	public function new(numChannel:Int, numSamples:Int, sampleRate:Int) {
		this.numChannel = numChannel;
		this.numSamples = numSamples;
		this.sampleRate = sampleRate;
	}
}

class DummyAudioChannel extends AudioChannel {
	public function new() {}

	public function isEnded():Bool {
		return true;
	}

	public function isPlaying():Bool {
		return false;
	}

	public function pause() {}

	public function resume() {}

	public function start() {}
}

class DummyAudioMixer extends AudioMixer {
	public function new() {}

	public function createAudioChannel(buffer:IAudioBuffer, loop:Bool):AudioChannel {
		return new DummyAudioChannel();
	}
}

class DummyBios extends BIOS {
	public function new() {
		super("Dummy Bios");
	}

	public function connect(res:RES):Void {}

	public function createAudioBuffer(audioStream:IAudioStream):IAudioBuffer {
		return new DummyAudioBuffer(audioStream.numChannels, audioStream.numSamples, audioStream.sampleRate);
	}

	public function createAudioMixer():AudioMixer {
		return new DummyAudioMixer();
	}

	public function createCRT(width:Int, height:Int):CRT {
		return new DummyCRT();
	}

	public function createStorage():Storage {
		return new DummyStorage();
	}

	public function startup():Void {}
}
