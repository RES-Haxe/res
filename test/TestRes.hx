import res.Palette;
import res.RES;
import res.Rom;
import utest.Assert;
import utest.Async;
import utest.Test;

class TestRes extends Test {
	public function testRes(async:Async) {
		RES.boot(new DummyBios(), {
			resolution: [100, 100],
			rom: new Rom(Palette.createDefault(), {})
		}, (res) -> {
            Assert.notNull(res);
			async.done();
		});
	}
}
