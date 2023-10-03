import Bios.bios;
import res.RES;
import res.rom.RomFlash;

function main() {
	RES.boot(bios, {
		resolution: [128, 128],
		rom: RomFlash.embed('rom'),
		main: (res) -> {
			return {
				update: (dt) -> {},
				render: (fb) -> {
					fb.clear();
				}
			}
		}
	});
}
