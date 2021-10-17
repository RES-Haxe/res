package res.audio;

interface IAudioMixer {
	public final playing:Array<AudioChannel>;

	function createAudioChannel(buffer:IAudioBuffer, ?loop:Bool):AudioChannel;

	/**
		Play an audio buffer

		@param buffer Audio buffer
	 */
	function play(buffer:IAudioBuffer, ?loop:Bool = false):AudioChannel;

	/** 
		Pause all sounds
	 */
	function pause():Void;

	/**
		Resume all sounds
	 */
	function resume():Void;
}
