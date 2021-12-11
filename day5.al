MODE LINE = STRUCT (
  INT x1, y1, x2, y2
);

PROC read lines = (REF FILE in, REF BOOL finished reading) REF []LINE:
BEGIN
  REF FLEX []LINE lines := HEAP FLEX [1:8]LINE;

  INT line i := 1;
  WHILE
    NOT finished reading
  DO
    INT x1, y1, x2, y2;
    getf(in, ($g, ",", g, " -> ", g, ",", g$, x1, y1, x2, y2));

    IF NOT finished reading THEN
      IF line i > UPB lines THEN
        REF FLEX[]LINE new lines = HEAP FLEX [2 * UPB lines]LINE;
        new lines[:UPB lines] := lines;
        lines := new lines
      FI;
      lines[line i] := (x1, y1, x2, y2);
      line i +:= 1
    FI
  OD;

  REF FLEX []LINE(lines) := lines[:line i-1];
  lines
END;

PROC min = (INT a, INT b) INT:
BEGIN
  IF a < b THEN
    a
  ELSE
    b
  FI
END;

PROC max = (INT a, INT b) INT:
BEGIN
  IF a > b THEN
    a
  ELSE
    b
  FI
END;

PROC get grid dimensions = (REF []LINE lines, REF INT xoff, yoff, width, height) VOID:
BEGIN
  INT maxx := x1 OF lines[1];
  INT maxy := y1 OF lines[1];
  INT minx := x1 OF lines[1];
  INT miny := y1 OF lines[1];

  FOR i FROM LWB lines TO UPB lines DO
    minx := min(minx, min(x1 OF lines[i], x2 OF lines[i]));
    miny := min(miny, min(y1 OF lines[i], y2 OF lines[i]));
    maxx := max(maxx, max(x1 OF lines[i], x2 OF lines[i]));
    maxy := max(maxy, max(y1 OF lines[i], y2 OF lines[i]))
  OD;

  xoff := 1 - minx;
  yoff := 1 - miny;
  width := maxx - minx + 1;
  height := maxy - miny + 1
END;

PROC count danger points = (REF []LINE lines, BOOL include diagonals, INT xoff, yoff, width, height) INT:
BEGIN
  REF [,]INT grid = HEAP [width,height]INT;
  INT danger points := 0;

  FOR x FROM 1 TO width DO
    FOR y FROM 1 TO height DO
      grid[x,y] := 0
    OD
  OD;
  
  FOR i FROM LWB lines TO UPB lines DO
    LINE l := lines[i];

    IF x1 OF l = x2 OF l THEN
      FOR y FROM min(y1 OF l, y2 OF l) TO max(y1 OF l, y2 OF l) DO
        grid[xoff + x1 OF l, yoff + y] +:= 1;
        IF grid[xoff + x1 OF l, yoff + y] = 2 THEN
          danger points +:= 1
        FI
      OD
    ELIF y1 OF l = y2 OF l THEN
      FOR x FROM min(x1 OF l, x2 OF l) TO max(x1 OF l, x2 OF l) DO
        grid[xoff + x, yoff + y1 OF l] +:= 1;
        IF grid[xoff + x, yoff + y1 OF l] = 2 THEN
          danger points +:= 1
        FI
      OD
    ELIF include diagonals AND ABS(x1 OF l - x2 OF l) = ABS(y1 OF l - y2 OF l) THEN
      INT length := ABS(x1 OF l - x2 OF l);
      INT startx := x1 OF l;
      INT starty := y1 OF l;
      INT xs := IF x1 OF l < x2 OF l THEN 1 ELSE -1 FI;
      INT ys := IF y1 OF l < y2 OF l THEN 1 ELSE -1 FI;
      FOR i FROM 0 TO length DO
         INT xc := xoff + startx + (i*xs);
         INT yc := yoff + starty + (i*ys);
         grid[xc, yc] +:= 1;
         IF grid[xc, yc] = 2 THEN
           danger points +:= 1
         FI
      OD
    FI
  OD;

  danger points
END;

PROC main = VOID:
BEGIN
  FILE in;

  open(in, "data/data5.txt", stand in channel);
  BOOL finished reading := FALSE;
  on logical file end (in, (REF FILE f) BOOL: finished reading := TRUE);
  on format error (in, (REF FILE f) BOOL: finished reading := TRUE);

  REF FLEX []LINE lines := read lines(in, finished reading);
  close(in);

  INT xoff, yoff, width, height;
  get grid dimensions(lines, xoff, yoff, width, height);
  
  INT part 1 n danger points := count danger points(lines, FALSE, xoff, yoff, width, height);
  INT part 2 n danger points := count danger points(lines, TRUE, xoff, yoff, width, height);

  printf(($"Part 1: number of danger points = ", g(0)l$, part 1 n danger points));
  printf(($"Part 2: number of danger points = ", g(0)l$, part 2 n danger points))
END;

main
