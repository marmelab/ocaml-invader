type direction =
    | Left
    | Right

type collision = {
    bullet: Bullet.bullet;
    invader: Invader.invader;
}

type action =
    | Move of direction
    | Shoot
    | AdvanceInvaders
    | InvaderShoot
    | AdvanceBullets
    | CheckCollisions

type game = {
    mutable over: bool;
    mutable score: int;
    mutable lifes: int;
    mutable invaders: Invader.invader list;
    mutable invadersDirection: direction;
    mutable spaceship: Spaceship.spaceship;
    mutable bullets: Bullet.bullet list;
}

let findOutOfBoundsInvader = let open Invader in
    let check = Utils.isOutOfBounds ~bounds: (50., 50., 400., 600.) in
    fun invaders ->
        try Some (List.find (fun invader -> check(invader.x, invader.y)) invaders)
        with Not_found -> None

let invaderIncrementResolver ~direction ~forward =
    match direction with
        | Left when forward -> -10., -15.
        | Right when forward -> 10., -15.
        | Left when not forward -> -10., 0.
        | Right when not forward -> 10., 0.
        | _ -> 0., 0.

let invaderDirectionGuesser ~game =
    match findOutOfBoundsInvader game.invaders with
        | None -> game.invadersDirection
        | Some(_) -> match game.invadersDirection with
            | Left -> Right
            | Right -> Left

let rec collectInvadersCollisions ~invaders ~bullets = let open Bullet in
    match invaders with
        | [] -> []
        | hd :: tl ->
            let checkHit = isInBoundsBullet ~bounds: (Invader.collisionBounds hd) in
              match List.find_opt checkHit bullets with
                | None -> collectInvadersCollisions ~invaders: tl ~bullets: bullets
                | Some(bullet) -> {
                    invader = hd;
                    bullet;
                } :: collectInvadersCollisions ~invaders: tl ~bullets: bullets

let collectInvaderBulletCollisions ~game = let open Bullet in
    let spaceshipBullets = List.filter (fun bullet -> bullet.shooter == Spaceship) game.bullets in
    let collisions = collectInvadersCollisions ~invaders:game.invaders ~bullets:spaceshipBullets in
    collisions

let getSpaceshipCollisionBullet ~game = let open Bullet in
    let invaderBullets = List.filter (fun bullet -> bullet.shooter == Invader) game.bullets in
    let checkHit = isInBoundsBullet ~bounds: (Spaceship.collisionBounds game.spaceship) in
    List.find_opt checkHit invaderBullets

let controller game = function
    | Move(direction) ->
        let op = match direction with
        | Left -> (-.)
        | Right -> (+.) in
        let coord = op game.spaceship.x 10. in
        game.spaceship.x <- min (max coord 10.) 440.;
        game
    | Shoot ->
        game.bullets <- game.bullets @ [{
            x = game.spaceship.x;
            y = game.spaceship.y;
            shooter = Spaceship
        }];
        game
    | InvaderShoot ->
        if List.length game.invaders > 0 then
            let invader = Utils.randomPick game.invaders in
            game.bullets <- game.bullets @ [{
                x = invader.x;
                y = invader.y;
                shooter = Invader
            }]
        else ();
        game
    | CheckCollisions -> (
        let lifes = match getSpaceshipCollisionBullet ~game with
            | None -> game.lifes
            | _ -> game.lifes - 1 in
        let invaderCollisions = collectInvaderBulletCollisions ~game in
            game.invaders <- List.filter (fun invader ->
                match (List.find_opt (fun col -> col.invader == invader) invaderCollisions) with
                    | None -> true
                    | _ -> false
            ) game.invaders;
            game.bullets <- List.filter (fun bullet ->
                (match getSpaceshipCollisionBullet ~game with
                    | None -> true
                    | Some(b) -> b != bullet) &&
                (match (List.find_opt (fun col -> col.bullet == bullet) invaderCollisions) with
                    | None -> true
                    | _ -> false)
            ) game.bullets;
            game.score <- (40 - List.length game.invaders) * 15;
            game.lifes <- lifes;
            game.over <- game.lifes <= 0 || game.score >= 600;
        game
    )
    | AdvanceInvaders ->
        let direction = invaderDirectionGuesser ~game in
            let forward = game.invadersDirection != direction in
            let increment = invaderIncrementResolver ~direction ~forward in
            let advanceInvaders = Invader.advance ~increment in
            game.invadersDirection <- direction;
            game.invaders <- List.map (advanceInvaders) game.invaders;
        game
    | AdvanceBullets ->
        let bullets = List.map Bullet.advance game.bullets in
            game.bullets <- List.filter (Bullet.isInBoundsBullet ~bounds: (50., 50., 400., 600.)) bullets;
        game

let renderHome game =
    GlClear.clear [ `color ];
    GlMat.load_identity ();
    GlMat.translate3(225., 300., 0.0);
    GlDraw.color(1., 0., 0.);
    GlDraw.begins `quads;
    List.iter GlDraw.vertex2 [-150., -100.; -150., 100.; 150., 100.; 150., -100.];
    GlDraw.color (0., 0., 0.);
    GlDraw.ends ();
    let endText = match game.score with
        | 600 -> Printf.sprintf "YOU WIN"
        | _ -> Printf.sprintf "GAME OVER" in
    Utils.drawString ~font:Glut.BITMAP_TIMES_ROMAN_24 150. 290.  endText;
    Glut.swapBuffers ()

let renderGame game =
    GlClear.clear [ `color ];
    Score.render game.score;
    Life.render game.lifes;
    List.iter Invader.render game.invaders;
    List.iter Bullet.render game.bullets;
    Spaceship.render game.spaceship;
    Glut.swapBuffers ()

let render game =
    match game.over with
        | false -> renderGame game
        | true -> renderHome game

let invaders = let open Invader in [
    { x = 40.;  y = 500.; race = ShapeShifting };
    { x = 80.;  y = 500.; race = ShapeShifting };
    { x = 120.; y = 500.; race = ShapeShifting };
    { x = 160.; y = 500.; race = ShapeShifting };
    { x = 200.; y = 500.; race = ShapeShifting };
    { x = 240.; y = 500.; race = ShapeShifting };
    { x = 280.; y = 500.; race = ShapeShifting };
    { x = 320.; y = 500.; race = ShapeShifting };
    { x = 40.;  y = 460.; race = Octopus };
    { x = 80.;  y = 460.; race = Octopus };
    { x = 120.; y = 460.; race = Octopus };
    { x = 160.; y = 460.; race = Octopus };
    { x = 200.; y = 460.; race = Octopus };
    { x = 240.; y = 460.; race = Octopus };
    { x = 280.; y = 460.; race = Octopus };
    { x = 320.; y = 460.; race = Octopus };
    { x = 40.;  y = 420.; race = Octopus };
    { x = 80.;  y = 420.; race = Octopus };
    { x = 120.; y = 420.; race = Octopus };
    { x = 160.; y = 420.; race = Octopus };
    { x = 200.; y = 420.; race = Octopus };
    { x = 240.; y = 420.; race = Octopus };
    { x = 280.; y = 420.; race = Octopus };
    { x = 320.; y = 420.; race = Octopus };
    { x = 40.;  y = 380.; race = Crab };
    { x = 80.;  y = 380.; race = Crab };
    { x = 120.; y = 380.; race = Crab };
    { x = 160.; y = 380.; race = Crab };
    { x = 200.; y = 380.; race = Crab };
    { x = 240.; y = 380.; race = Crab };
    { x = 280.; y = 380.; race = Crab };
    { x = 320.; y = 380.; race = Crab };
    { x = 40.;  y = 340.; race = Crab };
    { x = 80.;  y = 340.; race = Crab };
    { x = 120.; y = 340.; race = Crab };
    { x = 160.; y = 340.; race = Crab };
    { x = 200.; y = 340.; race = Crab };
    { x = 240.; y = 340.; race = Crab };
    { x = 280.; y = 340.; race = Crab };
    { x = 320.; y = 340.; race = Crab };
]

let spaceship = let open Spaceship in {
    x = 225.;
    y = 50.;
}

let init () = {
    over = false;
    score = 0;
    lifes = 3;
    spaceship;
    invaders;
    invadersDirection = Left;
    bullets = [];
}
