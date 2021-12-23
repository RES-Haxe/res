package res.collisions;

import Math.*;
import res.geom.Vector2;
import res.tools.MathTools.*;
import res.types.Shape;

class Collider {
	/**
		Tests collision between two shapes

		@param shape Shape to test the collision against
		@param versus Shape to test the collision with
	 */
	public static function collide(shape:Shape, versus:Shape):CollisionResult {
		switch (shape) {
			case CIRCLE(cx, cy, r):
				switch (versus) {
					case CIRCLE(vcx, vcy, vr):
						final dist = sqrt(pow(vcx - cx, 2) + pow(vcy - cy, 2));
						if (dist < r + vr) {
							final v = new Vector2(vcx - cx, vcy - cy);
							v.normalize((r + vr) - dist);
							return OFFSET(v.x, v.y);
						}
					case RECT(vrx, vry, vrw, vrh):
						switch (collide(RECT(vrx, vry, vrw, vrh), CIRCLE(cx, cy, r))) {
							case OFFSET(dx, dy):
								return OFFSET(-dx, -dy);
							case NONE:
								return NONE;
						}
				}
			case RECT(rx, ry, rw, rh):
				switch (versus) {
					case CIRCLE(vcx, vcy, vr):
						if ((vcx >= rx - rw / 2 && vcx <= rx + rw / 2) || (vcy >= ry - rh / 2 && vcy <= ry + rh / 2))
							return collide(RECT(rx, ry, rw, rh), RECT(vcx, vcy, vr * 2, vr * 2));

						final corners = [[rx - rw / 2, ry - rh / 2], [rx + rw / 2, ry - rh / 2], [rx + rw / 2, ry + rh / 2], [rx - rw / 2, ry + rh / 2]];

						for (corner in corners) {
							final result = collide(CIRCLE(corner[0], corner[1], 0), CIRCLE(vcx, vcy, vr));

							switch (result) {
								case OFFSET(dx, dy):
									return OFFSET(dx, dy);
								case _:
							}
						}

					case RECT(vrx, vry, vrw, vrh):
						final dx = vrx - rx;
						final dy = vry - ry;

						if (abs(dx) <= rw / 2 + vrw / 2 && abs(dy) <= rh / 2 + vrh / 2) {
							final ox = (rw / 2 + vrw / 2) - abs(dx);
							final oy = (rh / 2 + vrh / 2) - abs(dy);

							if (ox < oy) {
								return OFFSET(ox * sign(dx), 0);
							} else {
								return OFFSET(0, oy * sign(dy));
							}
						}
				}
		}
		return NONE;
	}
}
