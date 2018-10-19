type shooter =
  | Invader
  | Spaceship

type bullet = {
  mutable x: float;
  mutable y: float;
  shooter: shooter;
}

let isInBoundsBullet ~bounds =
    let check = Utils.isOutOfBounds ~bounds in
    fun bullet -> not @@ check(bullet.x, bullet.y)

let advance bullet =
    let _ = match bullet with
    | { shooter = Invader } -> bullet.y <- (bullet.y -. 8.)
    | { shooter = Spaceship } -> bullet.y <- (bullet.y +. 8.) in
    bullet

let renderInvaderBullet () =
  GlDraw.color(1., 0.3, 0.3);
  GlDraw.begins `quads;
  List.iter GlDraw.vertex2 [-3., -3.; -3., 3.; 3., 3.; 3., -3.];
  GlDraw.ends ()

let renderSpaceshipBullet () =
  GlDraw.color(1., 1., 1.);
  GlDraw.begins `quads;
  List.iter GlDraw.vertex2 [-3., -3.; -3., 3.; 3., 3.; 3., -3.];
  GlDraw.ends ()

let render bullet =
  GlMat.load_identity ();
  GlMat.translate3(bullet.x, bullet.y, 0.);
  match bullet.shooter with
    | Invader -> renderInvaderBullet()
    | Spaceship -> renderSpaceshipBullet()
