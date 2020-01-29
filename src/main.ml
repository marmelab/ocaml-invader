let specialKeyToAction ~key ~x ~y =
  match key with
  | 27 -> exit 0;
  | 32 -> Some Game.Shoot
  | _ -> None

let commonKeyToAction ~key ~x ~y =
  match key with
    | Glut.KEY_LEFT -> Some(Game.Move(Left))
    | Glut.KEY_RIGHT -> Some(Game.Move(Right))
    | _ -> None

let gameController game keyToAction = fun ~key ~x ~y ->
  match (keyToAction ~key ~x ~y) with
    | Some(action) -> game := Game.controller !game action
    | None -> ()

let rec invaderTicker game = fun ~value ->
  game := Game.controller !game Game.AdvanceInvaders;
  game := (
    match Random.bool() with
    | true -> Game.controller !game Game.InvaderShoot
    | false -> !game
  );
  Glut.timerFunc ~ms:1000 ~cb:(invaderTicker game) ~value:0

let rec bulletTicker game = fun ~value ->
  game := Game.controller !game Game.AdvanceBullets;
  Glut.timerFunc ~ms:10 ~cb:(bulletTicker game) ~value:0

let rec collisionCheckTicker game = fun ~value ->
  game := Game.controller !game Game.CheckCollisions;
  Glut.timerFunc ~ms:10 ~cb:(collisionCheckTicker game) ~value:0

let initDisplay ~w ~h ~title =
  Glut.initDisplayMode ~double_buffer:true ~depth:true ~alpha:true ();
  Glut.initWindowSize ~w ~h;
  Glut.createWindow ~title;
  Glut.idleFunc ~cb:(Some Glut.postRedisplay)

let initView ~w ~h =
  GlDraw.viewport ~x:0 ~y:0 ~w ~h;
  GlMat.mode `projection;
  GlMat.load_identity ();
  GluMat.ortho2d ~x:(0.0, float_of_int(w)) ~y:(0.0, float_of_int(h));
  GlMat.mode `modelview

let initTickers ~game =
  Glut.timerFunc ~ms:1000 ~cb:(invaderTicker game) ~value:0;
  Glut.timerFunc ~ms:10 ~cb:(bulletTicker game) ~value:0;
  Glut.timerFunc ~ms:10 ~cb:(collisionCheckTicker game) ~value:0

let initInputs ~game =
  Glut.keyboardFunc ~cb:(gameController game specialKeyToAction);
  Glut.specialFunc ~cb:(gameController game commonKeyToAction)

let initEngine ~game ~w ~h =
  initDisplay ~w ~h ~title: "OCaml Invader";
  initView ~w ~h;
  initTickers ~game;
  initInputs ~game;
  Glut.displayFunc (fun () -> Game.render !game);
  Glut.mainLoop

let () =
  ignore @@ Glut.init Sys.argv;
  let game = ref (Game.init()) in
  let run = initEngine ~game ~w:450 ~h:600 in
    run()
