package res.bios;

import res.audio.AudioMixer;
import res.audio.IAudioBuffer;
import res.audio.IAudioStream;
import res.display.FrameBuffer;
import res.storage.IStorage;

abstract class BIOS {
	public final name:String;

	abstract public function connect(res:RES):Void;

	abstract public function createAudioBuffer(audioStream:IAudioStream):IAudioBuffer;

	abstract public function createAudioMixer():AudioMixer;

	abstract public function createFrameBuffer(width:Int, height:Int, palette:Palette):FrameBuffer;

	abstract public function createStorage():IStorage;

	public function new(name:String) {
		this.name = name;
	}
}
