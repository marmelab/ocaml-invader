type race =
    | Octopus
    | ShapeShifting
    | Crab

type invader = {
  mutable x: float;
  mutable y: float;
  race: race;
}

let collisionBounds invader = (
    invader.x -. 10.,
    invader.y -. 10.,
    invader.x +. 10.,
    invader.y +. 10.
)

let advance ~increment =
    let (x, y) = increment in
    fun invader ->
        invader.x <- invader.x +. x;
        invader.y <- invader.y +. y;
        invader

let renderOctopus () =
    GlDraw.color(1., 1., 1.);
    GlDraw.begins `quads;
    List.iter GlDraw.vertex2 [-10., -10.; -10., 10.; 10., 10.; 10., -10.];
    GlDraw.ends ()

let renderCrab () =
    GlDraw.color(1., 0., 1.);
    GlDraw.begins `quads;
    List.iter GlDraw.vertex2 [-10., -10.; -10., 10.; 10., 10.; 10., -10.];
    GlDraw.ends ()

let renderShapeShifting () =
    GlDraw.color(1., 0., 0.);
    GlDraw.begins `quads;
    List.iter GlDraw.vertex2 [-10., -10.; -10., 10.; 10., 10.; 10., -10.];
    GlDraw.ends ()

let render invader =
    GlMat.load_identity ();
    GlMat.translate3(invader.x, invader.y, 0.0);
    match invader.race with
        | Octopus -> renderOctopus()
        | ShapeShifting -> renderShapeShifting()
        | Crab -> renderCrab()
