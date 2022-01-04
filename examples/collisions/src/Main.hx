import res.RES;
import res.features.fonts.KernalFont;
import res.platform.js.Html5Platform;
import res.rom.Rom;

function main() {
	RES.boot(new Html5Platform(), {
		resolution: PIXELS(256, 256),
		rom: Rom.embed('rom'),
		mainScene: MainScene,
		features: [KernalFont]
	});
}
