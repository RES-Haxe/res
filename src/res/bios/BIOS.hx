package res.bios;

import res.audio.AudioMixer;
import res.audio.IAudioBuffer;
import res.audio.IAudioStream;
import res.display.CRT;
import res.storage.Storage;

abstract class BIOS {
	public final name:String;

	abstract public function connect(res:RES):Void;

	abstract public function createAudioBuffer(audioStream:IAudioStream):IAudioBuffer;

	abstract public function createAudioMixer():AudioMixer;

	abstract public function createCRT(width:Int, height:Int):CRT;

	abstract public function createStorage():Storage;

	/**
		Implement any preperational code here and call `cb` whenever BIOS is
		ready to be connected with the RES instance
	**/
	public function ready(cb:Void->Void)
		cb();

	/**
		Will be called when everything is ready to start the game
	**/
	abstract public function startup():Void;

	/**
		Preform the cleanup and shutdown actions here
	**/
	public function shutdown() {}

	public function new(name:String) {
		this.name = name;
	}
}
