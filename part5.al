MODE LINE = STRUCT (
  INT x1, y1, x2, y2
);

PROC read lines = (REF FILE in, REF BOOL finished reading, REF FLEX []LINE lines) VOID:
BEGIN
  lines := HEAP FLEX [1:8]LINE;

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
      line i := line i + 1
    FI
  OD;

  lines := lines[:line i-1]
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

PROC get grid dimensions = (REF FLEX []LINE lines, REF INT xoff, yoff, width, height) VOID:
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

PROC count danger points = (REF FLEX []LINE lines, INT xoff, yoff, width, height) INT:
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
        grid[xoff + x1 OF l, yoff + y] := grid[xoff + x1 OF l, yoff + y] + 1;
        IF grid[xoff + x1 OF l, yoff + y] = 2 THEN
          danger points := danger points + 1
        FI
      OD
    ELIF y1 OF l = y2 OF l THEN
      FOR x FROM min(x1 OF l, x2 OF l) TO max(x1 OF l, x2 OF l) DO
        grid[xoff + x, yoff + y1 OF l] := grid[xoff + x, yoff + y1 OF l] + 1;
        IF grid[xoff + x, yoff + y1 OF l] = 2 THEN
          danger points := danger points + 1
        FI
      OD
    FI
  OD;

  danger points
END;

PROC main = VOID:
BEGIN
  FILE in;

  open(in, "data5.txt", stand in channel);
  BOOL finished reading := FALSE;
  on logical file end (in, (REF FILE f) BOOL: finished reading := TRUE);
  on format error (in, (REF FILE f) BOOL: finished reading := TRUE);

  REF FLEX []LINE lines := LOC [1:0]LINE;
  read lines(in, finished reading, lines);
  close(in);

  INT xoff, yoff, width, height;
  get grid dimensions(lines, xoff, yoff, width, height);
  
  INT n danger points := count danger points(lines, xoff, yoff, width, height);

  printf(($"Number of danger points = ", 10zdl$, n danger points))
END;

main
