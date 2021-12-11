MODE COORD = STRUCT (
  INT x, y
);

PROC read input = (STRING filename) REF FLEX []REF[]INT:
BEGIN
  FILE in;

  open(in, filename, stand in channel);
  BOOL finished reading := FALSE;
  on logical file end (in, (REF FILE f) BOOL: finished reading := TRUE);
  on format error (in, (REF FILE f) BOOL: finished reading := TRUE);

  STRING line;
  get(in, (line, newline));

  INT n cols = UPB line;

  REF FLEX []REF[]INT rows := HEAP [1:8]REF[]INT;
  INT n rows := 1;
  WHILE NOT finished reading DO
    REF []INT row = HEAP [n cols]INT;

    FOR i FROM LWB line TO UPB line DO
      CHAR c := line[i];
      row[i] := ABS(c) - ABS("0")
    OD;

    IF n rows > UPB rows THEN
      REF FLEX []REF[]INT new rows = HEAP FLEX [UPB rows * 2]REF[]INT;
      new rows[:UPB rows] := rows;
      rows := new rows
    FI;
    rows[n rows] := row;

    n rows +:= 1;

    get(in, (line, newline))
  OD;

  close(in);

  REF FLEX []REF[]INT(rows) := rows[1:n rows -1];
  rows
END;

PROC find low points = (REF []REF[]INT rows, REF FLEX[]COORD points) VOID:
BEGIN
  INT n points := 0;
  FOR y FROM 1 TO UPB rows DO
    FOR x FROM 1 TO UPB rows[y] DO
      INT upy = y - 1;
      INT downy := y + 1;
      INT leftx := x - 1;
      INT rightx := x +1;
      INT val := rows[y][x];

      BOOL low point := TRUE;

      # Fun fact: Algol 68 doesn't have short-circuiting boolean operators! #
      # To avoid out of range indexing, we use nested IFs instead.          #
      IF (IF upy > 0 THEN rows[upy][x] <= val ELSE FALSE FI) THEN
        low point := FALSE
      ELIF (IF downy <= UPB rows THEN rows[downy][x] <= val ELSE FALSE FI) THEN
        low point := FALSE
      ELIF (IF leftx > 0 THEN rows[y][leftx] <= val ELSE FALSE FI) THEN
        low point := FALSE
      ELIF (IF rightx <= UPB rows[1] THEN rows[y][rightx] <= val ELSE FALSE FI) THEN
        low point := FALSE
      FI;

      IF low point THEN
        n points +:= 1;
        points[n points] := (x, y)
      FI
    OD
  OD;

  points := points[:n points]
END;

PROC total risk = (REF []REF[]INT rows, REF FLEX[]COORD low points) INT:
BEGIN
  INT risk := 0;
  FOR i FROM LWB low points TO UPB low points DO
    INT x := x OF low points[i];
    INT y := y OF low points[i];
    INT v := rows[y][x];
    risk +:= v + 1
  OD;

  risk
END;

PROC smallest 3 basins = (REF []REF[]INT rows, REF FLEX[]COORD low points) INT:
BEGIN
  INT b1 := 0;
  INT b2 := 0;
  INT b3 := 0;

  # worst case is one basin containing every point (?) #
  REF []COORD basin := HEAP [UPB rows * UPB rows[1]]COORD;
  REF [,]BOOL basin map := HEAP [UPB rows, UPB rows[1]]BOOL;

  # only have to initialize this once because basins are non-overlapping #
  FOR r FROM LWB rows TO UPB rows DO
    FOR c FROM LWB rows[1] TO UPB rows[1] DO
      basin map[r,c] := FALSE
    OD
  OD;

  FOR lpi FROM LWB low points TO UPB low points DO
    INT basin size := 1;
    basin[1] := low points[lpi];
    INT last basin size := 0;
    WHILE last basin size /= basin size DO
      INT start := last basin size + 1;
      last basin size := basin size;

      FOR bpi FROM start TO basin size DO
        INT x := x OF basin[bpi];
        INT y := y OF basin[bpi];

        INT upy = y - 1;
        INT downy := y + 1;
        INT leftx := x - 1;
        INT rightx := x + 1;
        INT val := rows[y][x];

        IF (IF upy > 0 THEN rows[upy][x] >= val AND rows[upy][x] /= 9 AND NOT basin map[upy,x] ELSE FALSE FI) THEN
          basin size +:= 1;
          basin[basin size] := (x, upy);
          basin map[upy, x] := TRUE
        FI;
        IF (IF downy <= UPB rows THEN rows[downy][x] >= val AND rows[downy][x] /= 9 AND NOT basin map[downy, x] ELSE FALSE FI) THEN
          basin size +:= 1;
          basin[basin size] := (x, downy);
          basin map[downy, x] := TRUE
        FI;
        IF (IF leftx > 0 THEN rows[y][leftx] >= val AND rows[y][leftx] /= 9 AND NOT basin map[y, leftx] ELSE FALSE FI) THEN
          basin size +:= 1;
          basin[basin size] := (leftx, y);
          basin map[y, leftx] := TRUE
        FI;
        IF (IF rightx <= UPB rows[1] THEN rows[y][rightx] >= val AND rows[y][rightx] /= 9 AND NOT basin map[y, rightx] ELSE FALSE FI) THEN
          basin size +:= 1;
          basin[basin size] := (rightx, y);
          basin map[y, rightx] := TRUE
        FI
      OD
    OD;

    IF basin size > b1 AND basin size > b2 AND basin size > b3 THEN
      b3 := b2;
      b2 := b1;
      b1 := basin size
    ELIF basin size > b2 AND basin size > b3 THEN
      b3 := b2;
      b2 := basin size
    ELIF basin size > b3 THEN
      b3 := basin size
    FI
  OD;

  b1 * b2 * b3
END;

PROC main = VOID:
BEGIN
  REF FLEX []REF[]INT rows := read input("data/data9.txt");

  # I haven't bothered to calculate the upper bound, but there can't be more #
  # than n/4 low points in a grid with n squares.                            #
  REF FLEX[]COORD low points := HEAP FLEX [(UPB rows * UPB rows[1]) OVER 4]COORD;

  find low points(rows, low points);
  INT risk := total risk(rows, low points);

  printf(($"Part 1: total risk = ", g(0)l$, risk));

  INT sn := smallest 3 basins(rows, low points);
  printf(($"Part 2: product of smallest three basin sizes = ", g(0)l$, sn))
END;

main
