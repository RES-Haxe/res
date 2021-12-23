package res.platforms.java;

import res.types.RESConfig;

using res.tools.ResolutionTools;

class JavaPlatform extends Platform {
	private final _frameBuffer:FrameBuffer;

	override function get_frameBuffer():FrameBuffer {
		return _frameBuffer;
	}

	override function get_name():String {
		return 'Java';
	}

	public function new(config:RESConfig) {
		super(config);

		final screenSize = config.resolution.pixelSize();

		_frameBuffer = new FrameBuffer(screenSize.width, screenSize.height, config.rom.palette);
	}

	override function connect(res:RES) {}

	override function playAudio(id:String) {}
}
