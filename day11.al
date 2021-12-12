INT n steps = 100;

MODE COORD = STRUCT (
  INT x, y
);

PROC read lines = (REF FILE in, REF BOOL finished reading) REF []STRING:
BEGIN
  REF FLEX []STRING lines := HEAP FLEX [1:8]STRING;

  INT line i := 1;
  WHILE
    NOT finished reading
  DO
    STRING line;
    get(in, (line, newline));

    IF NOT finished reading THEN
      IF line i > UPB lines THEN
        REF FLEX[]STRING new lines = HEAP FLEX [2 * UPB lines]STRING;
        new lines[:UPB lines] := lines;
        lines := new lines
      FI;
      lines[line i] := line;
      line i +:= 1
    FI
  OD;

  REF FLEX []STRING(lines) := lines[:line i-1];
  lines
END;

PROC lines to grid = ([]STRING lines) REF [,]INT:
BEGIN
  INT width = UPB lines[1];
  INT height = UPB lines;

  REF [,]INT grid := HEAP [width,height] INT;

  FOR i FROM LWB lines TO UPB lines DO
    FOR c FROM LWB lines[i] TO UPB lines[i] DO
      grid[c,i] := ABS(lines[i][c]) - ABS("0")
    OD
  OD;

  grid
END;

PROC increase adjacent = (REF [,]INT grid, INT x, INT y, INT n) VOID:
BEGIN
  []INT xcoords = (x,   x+1, x,   x-1, x-1, x+1, x+1, x-1);
  []INT ycoords = (y+1, y,   y-1, y,   y+1, y+1, y-1, y-1);

  FOR i FROM LWB xcoords TO UPB xcoords DO
    INT ax = xcoords[i];
    INT ay = ycoords[i];
    IF ax >= 1 AND ax <= UPB grid AND ay >= 1 AND ay <= UPB grid[1,] THEN
      grid[ax, ay] +:= n
    FI
  OD
END;

PROC simulate = (REF [,]INT grid, INT n steps, REF INT first sync) INT:
BEGIN
  [UPB grid, UPB grid[1,]]BOOL flashes;
  INT n flashes := 0;

  INT step := 0;
  WHILE step < n steps OR n steps = -1 DO
    step +:= 1;

    # increase all energy levels by 1 #
    FOR i FROM LWB grid TO UPB grid DO
      FOR j FROM LWB grid[i,] TO UPB grid[i,] DO
        grid[i,j] +:= 1
      OD
    OD;

    # do flashes #
    BOOL one flashed := TRUE;
    FOR i FROM LWB grid TO UPB grid DO
      FOR j FROM LWB grid[i,] TO UPB grid[i,] DO
        flashes[i,j] := FALSE
      OD
    OD;
    WHILE one flashed DO
      one flashed := FALSE;

      FOR i FROM LWB grid TO UPB grid DO
        FOR j FROM LWB grid[i,] TO UPB grid[i,] DO
          INT e := grid[i,j];
          IF e > 9 AND NOT flashes[i,j] THEN
            one flashed := TRUE;
            n flashes +:= 1;
            flashes[i, j] := TRUE;
            increase adjacent(grid, i, j, 1)
          FI
        OD
      OD
    OD;

    # set all that flashed to zero energy level #
    BOOL all flashed := TRUE;
    FOR i FROM LWB grid TO UPB grid DO
      FOR j FROM LWB grid[i,] TO UPB grid[i,] DO
        IF flashes[i,j] THEN
          grid[i,j] := 0
        ELSE
          all flashed := FALSE
        FI
      OD
    OD;

    IF (first sync :/=: NIL) AND all flashed THEN
      first sync := step;
      GO TO out
    FI
  OD;

out:
  n flashes
END;

PROC main = VOID:
BEGIN
  FILE in;

  open(in, "data/data11.txt", stand in channel);
  BOOL finished reading := FALSE;
  on logical file end (in, (REF FILE f) BOOL: finished reading := TRUE);
  on format error (in, (REF FILE f) BOOL: finished reading := TRUE);

  REF []STRING lines := read lines(in, finished reading);
  close(in);

  REF [,]INT grid := lines to grid(lines);

  INT n flashes = simulate(grid, n steps, NIL);
  printf(($"Part 1: number of flashes = ", g(0)l$, n flashes));

  INT first flash step := -1;
  simulate(grid, -1, first flash step);
  printf(($"Part 2: first step where all flash = ", g(0)l$, first flash step))
END;

main
