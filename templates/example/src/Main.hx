import Bios.bios;
import res.RES;
import res.State;
import res.FrameBuffer;
import res.RNG;
import res.rom.Rom;
import res.Mth.*;

final RES_LABEL = 'R E S';
final LABEL_SPEED = 50; // pixels per second

class MainState extends State {
  final pos:{x:Float, y:Float};
  final labelSize:{width:Int, height:Int};
  final move:{dx:Int, dy:Int};

  final xBound:Int;
  final yBound:Int;

  public function new(res) {
    super(res);

    labelSize = res.defaultFont.measure(RES_LABEL);

    xBound = res.width - labelSize.width;
    yBound = res.height - labelSize.height;

    pos = {
      x: RNG.rangef(0, xBound),
      y: RNG.rangef(0, yBound)
    };

    move = {
      dx: RNG.oneof([-1, 1]),
      dy: RNG.oneof([-1, 1])
    };
  }

  override function update(dt:Float) {
    pos.x += move.dx * (LABEL_SPEED * dt);
    pos.y += move.dy * (LABEL_SPEED * dt);

    var hasHit = false;

    if (pos.x < 0 || pos.x > xBound) {
      pos.x = clamp(pos.x, 0, xBound);
      move.dx *= -1;
      hasHit = true;
    }

    if (pos.y < 0 || pos.y > yBound) {
      pos.y = clamp(pos.y, 0, yBound);
      move.dy *= -1;
      hasHit = true;
    }

    if (hasHit)
      audio.play('hitHurt');
  }

  override function render(fb:FrameBuffer) {
    fb.clear();
    res.defaultFont.draw(fb, RES_LABEL, pos.x, pos.y);
  }
}

function main() {
  RES.boot(bios, {
    resolution: [128, 128],
    rom: Rom.embed('rom'),
    main: (res) -> new MainState(res)
  });
}
