MODE COORD = STRUCT (
  INT x, y
);

PROC read input = (STRING filename, REF FLEX []REF[]INT rows) VOID:
BEGIN
  FILE in;

  open(in, filename, stand in channel);
  BOOL finished reading := FALSE;
  on logical file end (in, (REF FILE f) BOOL: finished reading := TRUE);
  on format error (in, (REF FILE f) BOOL: finished reading := TRUE);

  STRING line;
  get(in, (line, newline));

  INT n cols = UPB line;

  rows := HEAP [1:8]REF[]INT;
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

  rows := rows[1:n rows -1]
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

PROC total risk = (REF []REF[]INT rows) INT:
BEGIN
  # I haven't bothered to calculate the upper bound, but there can't be more #
  # than n/4 low points in a grid with n squares.                            #
  REF FLEX[]COORD low points := HEAP FLEX [(UPB rows * UPB rows[1]) OVER 4]COORD;

  find low points(rows, low points);

  INT risk := 0;
  FOR i FROM LWB low points TO UPB low points DO
    INT x := x OF low points[i];
    INT y := y OF low points[i];
    INT v := rows[y][x];
    risk +:= v + 1
  OD;

  risk
END;

PROC main = VOID:
BEGIN
  REF FLEX []REF[]INT rows := LOC FLEX [1:0]REF[]INT;
  read input("data/data9.txt", rows);

  INT risk := total risk(rows);

  printf(($"Part 1: total risk = ", g(0)l$, risk))
END;

main
