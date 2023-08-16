import Bios.bios;
import res.RES;
import res.rom.Rom;

function main() {
	RES.boot(bios, {
		resolution: [128, 128],
		rom: Rom.embed('rom'),
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
