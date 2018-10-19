let render score =
    GlDraw.color (0.5, 1., 1.);
    Utils.drawString 20. 550. (Printf.sprintf "Score: %d" score);
