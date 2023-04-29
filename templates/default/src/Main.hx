import Bios.bios;

final RES_LABEL = 'R E S';
final LABEL_SPEED = 50; // pixels per second

class MainState extends State {
  var pos:{x:Float, y:Float};
  var labelSize:{width:Int, height:Int};
  var move:{dx:Int, dy:Int};

  var xBound:Int;
  var yBound:Int;

  override function init() {
    labelSize = res.defaultFont.measure(RES_LABEL);

    xBound = res.width - labelSize.width;
    yBound = res.height - labelSize.height;

    pos = {
      x: rangef(0, xBound),
      y: rangef(0, yBound)
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
      audioMixer.play('hitHurt');
  }

  override function render(fb:FrameBuffer) {
    fb.clear();
    res.defaultFont.draw(fb, RES_LABEL, pos.x.int(), pos.y.int());
  }
}

function main() {
  RES.boot(bios, {
    resolution: [128, 128],
    rom: Rom.embed(),
    main: (res) -> new MainState()
  });
}
