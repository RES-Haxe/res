package res.platform;

import res.audio.AudioMixer;
import res.audio.IAudioBuffer;
import res.audio.IAudioStream;
import res.display.FrameBuffer;
import res.storage.IStorage;

interface IPlatform {
	public final name:String;

	public function connect(res:RES):Void;

	public function createAudioBuffer(audioStream:IAudioStream):IAudioBuffer;

	public function createAudioMixer():AudioMixer;

	public function createFrameBuffer(width:Int, height:Int, palette:Palette):FrameBuffer;

	public function createStorage():IStorage;
}
