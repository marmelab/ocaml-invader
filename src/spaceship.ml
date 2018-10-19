type spaceship = {
    mutable x: float;
    mutable y: float;
}

let collisionBounds invader = (
    invader.x -. 30.,
    invader.y -. 5.,
    invader.x +. 30.,
    invader.y +. 5.
)

let renderAt ~x ~y =
    GlMat.load_identity ();
    GlMat.translate3(x, y, 0.);
    GlDraw.color(0.51, 1., 0.);
    GlDraw.begins `quads;
    List.iter GlDraw.vertex2 [-20., -5.; -20., 5.; 20., 5.; 20., -5.];
    List.iter GlDraw.vertex2 [-2., 5.; -2., 14.; 2., 14.; 2., 5.];
    GlDraw.ends ()

let render spaceship =
    renderAt ~x:spaceship.x ~y:spaceship.y
