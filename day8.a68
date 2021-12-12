MODE LINE = STRUCT (
  REF []BITS all digits, out digits
);

BITS one = BIN(1);

INT n segments = 7;

PROC parse line = (STRING line, REF []BITS all digits, REF []BITS out digits) VOID:
BEGIN
  INT digits i := 1;
  BITS current digit := BIN(0);
  BOOL in out digits := FALSE;
  FOR si FROM LWB line TO UPB line DO
    IF line[si] = " " THEN
      IF digits i = 0 THEN
        EMPTY
      ELIF in out digits THEN
        out digits[digits i] := current digit
      ELSE
        all digits[digits i] := current digit
      FI;
      digits i +:= 1;
      current digit := BIN(0)
    ELIF line[si] = "|" THEN
      in out digits := TRUE;
      digits i := 0;
      current digit := BIN(0)
    ELSE
      INT segn = ABS(line[si]) - ABS("a");
      current digit := current digit OR (one SHL segn)
    FI
  OD;
  out digits[digits i] := current digit
END;

PROC read lines = (REF FILE in, REF BOOL finished reading) REF []LINE:
BEGIN
  REF FLEX []LINE lines := HEAP FLEX [1:8]LINE;

  INT line i := 1;
  WHILE
    NOT finished reading
  DO
    STRING s;
    get(in, (s, newline));

    REF []BITS all digits = HEAP [1:10]BITS;
    REF []BITS out digits = HEAP [1:4]BITS;
    parse line(s, all digits, out digits);

    IF NOT finished reading THEN
      IF line i > UPB lines THEN
        REF FLEX[]LINE new lines = HEAP FLEX [2 * UPB lines]LINE;
        new lines[:UPB lines] := lines;
        lines := new lines
      FI;
      lines[line i] := (all digits, out digits);
      line i +:= 1
    FI
  OD;

  REF FLEX []LINE(lines) := lines[:line i-1];
  lines
END;

PROC get seg count = (BITS segment) INT:
BEGIN
  BITS s := segment;
  INT segcount := 0;
  FOR i FROM 1 TO n segments DO
    IF ABS(s AND BIN(1)) /= 0 THEN
      segcount +:= 1
    FI;
    s := s SHR 1
  OD;
  segcount
END;

PROC count easy digits = (REF []LINE lines) INT:
BEGIN
  INT n easy := 0;

  FOR li FROM LWB lines TO UPB lines DO
    REF []BITS digits := out digits OF lines[li];

    FOR i FROM LWB digits TO UPB digits DO
      BITS s = digits[i];
      INT segcount = get seg count(s);

      IF segcount = 2 OR segcount = 3 OR segcount = 4 OR segcount = 7 THEN
        n easy +:= 1
      FI
    OD
  OD;

  n easy
END;

PROC deduct = (REF []BITS digits input, REF []BITS output) VOID:
BEGIN
  BITS d1 := BIN(0);
  BITS d4 := BIN(0);
  BITS d7 := BIN(0);
  BITS d8 := BIN(127);

  FOR i FROM LWB digits input TO UPB digits input DO
    BITS d = digits input[i];
    INT sc := get seg count(d);
    IF sc = 2 THEN
      d1 := d
    ELIF sc = 4 THEN
      d4 := d
    ELIF sc = 3 THEN
      d7 := d
    FI
  OD;

  # 9 is the only 6 seg that overlaps with 4  #
  BITS d9 := BIN(0);
  FOR i FROM LWB digits input TO UPB digits input DO
    BITS d = digits input[i];
    IF get seg count(d) = 6 AND d = (d OR d4) THEN
      d9 := d
    FI
  OD;
  
  # 6 is the only 6 seg that doesn't overlap with  1 #
  BITS d6 := BIN(0);
  FOR i FROM LWB digits input TO UPB digits input DO
    BITS d = digits input[i];
    IF get seg count(d) = 6 AND d /= (d OR d1) THEN
      d6 := d
    FI
  OD;

  # 0 is the only other 6 seg #
  BITS d0 := BIN(0);
  FOR i FROM LWB digits input TO UPB digits input DO
    BITS d = digits input[i];
    IF get seg count(d) = 6 AND d /= d6 AND d /= d9 THEN
      d0 := d
    FI
  OD;

  # 3 is the only 5 seg that overlaps with 7 #
  BITS d3 := BIN(0);
  FOR i FROM LWB digits input TO UPB digits input DO
    BITS d = digits input[i];
    IF get seg count(d) = 5 AND d = (d OR d7) THEN
      d3 := d
    FI
  OD;

  # 2 is the only 5 seg x such that x + 4 = 0 #
  BITS d2 := BIN(0);
  FOR i FROM LWB digits input TO UPB digits input DO
    BITS d = digits input[i];
    IF get seg count(d) = 5 AND (d OR d4) = BIN(127) THEN
      d2 := d
    FI
  OD;

  # 5 is the only other 5 seg #
  BITS d5 := BIN(0);
  FOR i FROM LWB digits input TO UPB digits input DO
    BITS d = digits input[i];
    IF get seg count(d) = 5 AND d /= d2 AND d /= d3 THEN
      d5 := d
    FI
  OD;

  output := (d0, d1, d2, d3, d4, d5, d6, d7, d8, d9)
END;

PROC sum outputs = (REF []LINE lines) INT:
BEGIN
  INT sum := 0;
  FOR li FROM LWB lines TO UPB lines DO
    LINE l = lines[li];
    [1:10]BITS deducted digits;
    deduct(all digits OF l, deducted digits);

    INT n := 0;
    FOR di FROM LWB out digits OF l TO UPB out digits OF l DO
      FOR d FROM 1 TO 10 DO
        IF deducted digits[d] = (out digits OF l)[di] THEN
          n *:= 10;
          n +:= d-1
        FI
      OD
    OD;

    sum +:= n
  OD;
  sum
END;

PROC main = VOID:
BEGIN
  FILE in;

  open(in, "data/data8.txt", stand in channel);
  BOOL finished reading := FALSE;
  on logical file end (in, (REF FILE f) BOOL: finished reading := TRUE);
  on format error (in, (REF FILE f) BOOL: finished reading := TRUE);

  REF []LINE lines := read lines(in, finished reading);
  close(in);

  printf(($"Part 1: easy digit count = ", g(0)l$, count easy digits(lines)));

  INT sum := sum outputs(lines);

  printf(($"Part 2: sum = ", g(0)l$, sum))
END;

main
