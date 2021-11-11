import res.IFrameBuffer;
import res.Scene;
import res.audio.IAudioBuffer;
import res.audio.Note;
import res.audio.Tone;
import res.audio.WaveFunc.sine;
import res.collisions.Collider;
import res.geom.Vector2;
import res.input.MouseEvent;
import res.text.Textmap;
import res.timeline.Timeline;
import res.tools.MathTools.*;

using Std;
using res.display.Sprite;
using res.graphics.Painter;
using res.tiles.Tilemap;

typedef Block = {
	hits:Null<Int>,
	scores:Int,
	color:Int,
	?occupies:Array<{tileX:Int, tileY:Int}>
};

enum BlockType {
	XX;
	GR;
	OR;
	LB;
	GN;
	RD;
	BL;
	PR;
	YL;
	SL;
	GL;
}

typedef Pattern = Array<Array<BlockType>>;

typedef Ball = {
	position:Vector2,
	velocity:Vector2,
	stuck:Bool
};

final PATTERNS:Array<Pattern> = [
	[
		[XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX],
		[XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX],
		[XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX],
		[XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX],
		[SL, SL, SL, SL, SL, SL, SL, SL, SL, SL, SL],
		[RD, RD, RD, RD, RD, RD, RD, RD, RD, RD, RD],
		[BL, BL, BL, BL, BL, BL, BL, BL, BL, BL, BL],
		[OR, OR, OR, OR, OR, OR, OR, OR, OR, OR, OR],
		[PR, PR, PR, PR, PR, PR, PR, PR, PR, PR, PR],
		[GN, GN, GN, GN, GN, GN, GN, GN, GN, GN, GN],
	],
];

class Game extends Scene {
	final FIELD_COL:Int = 2;
	final FIELD_WIDTH_TILES:Int = 22;
	final BALL_RADIUS:Float = 2.5;
	final MIN_STEP:Float = 1;

	var bg:Tilemap;
	var blocks:Tilemap;
	var text:Textmap;
	var platformWidth:Int = 20; // Width of the middle part of the platform in pixels
	var platformX:Float;
	var platformY:Int;

	var ballSpeed:Float = 150;

	var paused:Bool = true;
	var ready:Bool = true;
	var timeline:Timeline;

	var balls:Array<Ball> = [];

	var wallBounceSound:IAudioBuffer;
	var platformBounceSound:IAudioBuffer;
	var blockBounceSound:IAudioBuffer;

	var score(default, set):Int = 0;

	function set_score(val:Int):Int {
		final str = '$val';
		text.textAt(text.hTiles - 1 - str.length, 7, str);
		return score = val;
	}

	function setBlock(x:Int, y:Int, block:Block) {
		block.occupies = [
			{tileX: x, tileY: y},
			{tileX: x + 1, tileY: y}
		];

		final idx:Int = block.hits == null || block.hits <= 1 ? 13 : 11;

		blocks.place(x, y, {index: idx, colorMap: [0, 1, block.color], data: block});
		blocks.place(x + 1, y, {index: idx + 1, colorMap: [0, 1, block.color], data: block});
	}

	function initBlocks(pattern:Pattern) {
		for (line in 0...pattern.length) {
			for (col in 0...pattern[line].length) {
				final type = pattern[line][col];
				final block:Block = switch (type) {
					case GR:
						{hits: null, color: 14, scores: 50};
					case OR:
						{hits: null, color: 4, scores: 60};
					case LB:
						{hits: null, color: 11, scores: 70};
					case GN:
						{hits: null, color: 7, scores: 80};
					case RD:
						{hits: null, color: 3, scores: 90};
					case BL:
						{hits: null, color: 10, scores: 100};
					case PR:
						{hits: null, color: 2, scores: 110};
					case YL:
						{hits: null, color: 5, scores: 120};
					case SL:
						{hits: 2, color: 14, scores: 200};
					case GL:
						{hits: 4, color: 5, scores: 400};
					case _: null;
				};

				if (block != null)
					setBlock(FIELD_COL + col * 2, 1 + line, block);
			}
		}
	}

	function initBackground() {
		bg = res.createTilemap(res.rom.tilesets['tiles']);

		bg.set(FIELD_COL - 1, 0, 1); // top left corner

		for (x in FIELD_COL...(FIELD_COL + FIELD_WIDTH_TILES)) {
			bg.set(x, 0, 2);
		}

		// top "doors"
		for (n in 0...2) {
			bg.set(FIELD_COL + 3 + n * 12, 0, 3, false, true, true);
			bg.set(FIELD_COL + 3 + n * 12 + 1, 0, 5, false, false, true);
			bg.set(FIELD_COL + 3 + n * 12 + 2, 0, 3, false, false, true);
		}

		bg.set(FIELD_COL + FIELD_WIDTH_TILES, 0, 4); // top right corner

		for (y in 1...bg.vTiles) {
			bg.set(FIELD_COL - 1, y, 6);
			bg.set(FIELD_COL + FIELD_WIDTH_TILES, y, 6);
		}

		// side "doors"
		for (n in 0...4) {
			for (x in [FIELD_COL - 1, FIELD_COL + FIELD_WIDTH_TILES]) {
				bg.set(x, 3 + n * 7, 3);
				bg.set(x, 3 + n * 7 + 1, 5);
				bg.set(x, 3 + n * 7 + 2, 3, false, true);
			}
		}

		// background pattern
		for (y in 1...bg.vTiles) {
			for (x in FIELD_COL...(FIELD_COL + FIELD_WIDTH_TILES)) {
				bg.set(x, y, (x + y) % 2 != 0 ? 8 : 10);
			}
		}
	}

	function initText() {
		text = res.createTextmap();
		text.textAt(25, 2, 'HIGH', [0, 3]);
		text.textAt(26, 3, 'SCORE', [0, 3]);
		text.textAt(26, 4, '50000');

		text.textAt(26, 6, '1UP', [0, 3]);
		text.textAt(29, 7, '00');

		text.textAt(11, 25, 'READY');
	}

	function spawnBall(x:Float, y:Float, velocity:Vector2):Ball {
		final newBall:Ball = {
			position: Vector2.xy(x, y),
			velocity: velocity,
			stuck: false
		};
		balls.push(newBall);
		return newBall;
	}

	override function init() {
		initBackground();
		initText();

		wallBounceSound = res.createAudioBuffer(new Tone(sine, Note.A5, 0.05, 0.5));
		platformBounceSound = res.createAudioBuffer(new Tone(sine, Note.D6, 0.05, 0.5));
		blockBounceSound = res.createAudioBuffer(new Tone(sine, Note.E4, 0.05, 0.5));

		blocks = res.createTilemap(res.rom.tilesets['tiles']);

		platformX = (FIELD_COL + FIELD_WIDTH_TILES / 2) * 8 / 2;
		platformY = res.frameBuffer.frameHeight - 36;

		spawnBall(platformX, platformY - 4 - 2, new Vector2()).stuck = true;

		timeline = new Timeline();
		timeline.after(2, (_) -> {
			ready = false;
			paused = false;
			text.textAt(11, 25, '');
		});

		initBlocks(PATTERNS[0]);

		res.mouse.x = (res.width / 2).int();
	}

	function drawPlatform(fb:IFrameBuffer) {
		final mStart:Int = (platformX - platformWidth / 2).int();
		fb.drawSprite(res.rom.sprites['platform_side'], mStart - 8, platformY - 4);
		fb.drawSprite(res.rom.sprites['platform_middle'], mStart, platformY - 4, platformWidth);
		fb.drawSprite(res.rom.sprites['platform_side'], mStart + platformWidth, platformY - 4, true);
	}

	function drawBall(fb:IFrameBuffer, ball:Ball) {
		fb.drawSprite(res.rom.sprites['ball'], (ball.position.x - BALL_RADIUS).int(), (ball.position.y - BALL_RADIUS).int(), false, false, false);
	}

	override function mouseEvent(event:MouseEvent) {
		switch (event) {
			case DOWN(_, _, _):
				for (ball in balls) {
					if (ball.stuck && !paused && !ready) {
						ball.velocity.set(sign(-1 + Math.random() * 2), -1).normalize(ballSpeed);
						ball.stuck = false;
					}
				}
			case _:
		}
	}

	function moveBall(ball:Ball, dt:Float) {
		if (!ball.stuck) {
			var remainingDistance = ball.velocity.length() * dt;
			var hasBlockCollision:Bool = false;

			do {
				var step:Float = Math.min(MIN_STEP, remainingDistance);
				var direction:Vector2 = ball.velocity.clone().normalize();

				remainingDistance -= step;

				ball.position.x += direction.x * step;
				ball.position.y += direction.y * step;

				final tileX:Int = Math.floor(ball.position.x / 8);
				final tileY:Int = Math.floor(ball.position.y / 8);

				final adjacentBlocks:Array<Block> = [];

				for (x in tileX - 1...tileX + 1) {
					for (y in tileY - 1...tileY + 1) {
						final tile = blocks.get(x, y);
						if (tile != null && tile.data != null && adjacentBlocks.indexOf(tile.data) == -1) {
							adjacentBlocks.push(tile.data);
						}
					}
				}

				for (block in adjacentBlocks) {
					final result = Collider.collide(RECT(block.occupies[0].tileX * 8 + 8, block.occupies[0].tileY * 8 + 4, 16, 8),
						RECT(ball.position.x, ball.position.y, BALL_RADIUS * 2, BALL_RADIUS * 2));

					switch (result) {
						case OFFSET(dx, dy):
							if (block.hits == null || --block.hits <= 0) {
								for (blockTile in block.occupies)
									blocks.empty(blockTile.tileX, blockTile.tileY);

								score += block.scores;
							}

							if (dx == 0)
								ball.velocity.y *= -1;
							if (dy == 0)
								ball.velocity.x *= -1;

							audioMixer.play(blockBounceSound);

							ball.position.x += dx;
							ball.position.y += dy;

							break;
						case _:
					}
				}

				if (hasBlockCollision) {}

				if (ball.position.y > res.height + 2) {
					paused = true;

					timeline.after(2, (_) -> {
						res.setScene(Game, true, true);
					});
					return;
				}

				if (ball.position.x - BALL_RADIUS <= FIELD_COL * 8) {
					ball.position.x = FIELD_COL * 8 + BALL_RADIUS;
					ball.velocity.x *= -1;
					audioMixer.play(wallBounceSound);
				}

				if (ball.position.x + BALL_RADIUS >= (FIELD_COL + FIELD_WIDTH_TILES) * 8) {
					ball.position.x = (FIELD_COL + FIELD_WIDTH_TILES) * 8 - BALL_RADIUS;
					ball.velocity.x *= -1;
					audioMixer.play(wallBounceSound);
				}

				if (ball.position.y - BALL_RADIUS <= (FIELD_COL * 8 - 8)) {
					ball.position.y = (FIELD_COL * 8 - 8) + BALL_RADIUS;
					ball.velocity.y *= -1;
					audioMixer.play(wallBounceSound);
				}

				if (ball.position.y >= platformY - 6 && ball.position.y < platformY + 4) {
					if (ball.position.x > platformX - platformWidth / 2 - 8 && ball.position.x < platformX + platformWidth / 2 + 8) {
						ball.position.y = platformY - 6;

						final ang = (Math.PI * 0.8) * ((ball.position.x - platformX) / (platformWidth + 16));
						ball.velocity.set(Math.sin(ang), -Math.cos(ang)).normalize(ballSpeed);
						audioMixer.play(platformBounceSound);
					}
				}
			} while (remainingDistance > 0 && !hasBlockCollision);
		}
	}

	function movePlatform() {
		final prevPos = platformX;
		platformX = clampf(res.mouse.x, FIELD_COL * 8 + (platformWidth / 2 + 8), (FIELD_COL + FIELD_WIDTH_TILES) * 8 - (platformWidth / 2 + 8));

		for (ball in balls) {
			if (ball.stuck)
				ball.position.x += platformX - prevPos;
		}
	}

	override function update(dt:Float) {
		timeline.update(dt);

		if (!paused) {
			movePlatform();

			for (ball in balls)
				moveBall(ball, dt);
		}
	}

	override function render(fb:IFrameBuffer) {
		fb.clear(clearColorIndex);

		fb.drawTilemap(bg);
		fb.drawTilemap(blocks);
		fb.drawTilemap(text);

		if (!ready) {
			drawPlatform(fb);

			for (ball in balls)
				drawBall(fb, ball);
		}
	}
}
