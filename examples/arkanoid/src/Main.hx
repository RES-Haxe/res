import res.RES;
import res.features.fonts.KernalFont;
import res.platforms.js.Html5Platform;
import res.rom.Rom;

function main() {
	RES.boot(new Html5Platform(3), {
		resolution: PIXELS(256, 240),
		mainScene: MainMenu,
		rom: Rom.embed('rom'),
		features: [KernalFont]
	});
}
