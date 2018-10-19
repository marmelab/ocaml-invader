let font = Glut.BITMAP_HELVETICA_18

let isOutOfBounds ~bounds =
    let (x1, y1, x2, y2) = bounds in
    fun (x, y) -> x < x1 || x > x2 || y < y1 || y > y2

let randomPick list =
    let n = Random.int (List.length list) in
    List.nth list n

let drawString ?(font=font) x y s =
    GlMat.load_identity ();
    GlPix.raster_pos ~x ~y ();
    String.iter (fun c -> Glut.bitmapCharacter ~font ~c:(Char.code c)) s
