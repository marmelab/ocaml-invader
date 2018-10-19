let render lifes =
    GlDraw.color (0.5, 1., 1.);
    Utils.drawString 350. 550. (Printf.sprintf "Lifes: %d" lifes);
