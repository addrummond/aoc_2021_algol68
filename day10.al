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

PROC calc score = (STRING line) LONG INT:
BEGIN
  [UPB line]CHAR stack;
  INT stacki := 0;

  LONG INT score := 0;

  FOR i FROM LWB line TO UPB line DO
    IF line[i] = "[" THEN
      stacki +:= 1;
      stack[stacki] := "]"
    ELIF line[i] = "{" THEN
      stacki +:= 1;
      stack[stacki] := "}"
    ELIF line[i] = "(" THEN
      stacki +:= 1;
      stack[stacki] := ")"
    ELIF line[i] = "<" THEN
      stacki +:= 1;
      stack[stacki] := ">"
    ELSE
      IF (IF stacki = 0 THEN TRUE ELSE line[i] /= stack[stacki] FI) THEN
        score :=
          IF line[i] = ")" THEN
            3
          ELIF line[i] = "]" THEN
            57
          ELIF line[i] = "}" THEN
            1197
          ELSE
            25137
          FI;

        GO TO out
      FI;

      stacki -:= 1
    FI
  OD;

out:
  score
END;

PROC get completion string = (STRING line) STRING:
BEGIN
  [UPB line]CHAR stack;
  INT stacki := 0;

  BOOL invalid := FALSE;

  FOR i FROM LWB line TO UPB line DO
    IF line[i] = "[" THEN
      stacki +:= 1;
      stack[stacki] := "]"
    ELIF line[i] = "{" THEN
      stacki +:= 1;
      stack[stacki] := "}"
    ELIF line[i] = "(" THEN
      stacki +:= 1;
      stack[stacki] := ")"
    ELIF line[i] = "<" THEN
      stacki +:= 1;
      stack[stacki] := ">"
    ELSE
      IF (IF stacki = 0 THEN TRUE ELSE line[i] /= stack[stacki] FI) THEN
        invalid := TRUE;
        GO TO out
      FI;

      stacki -:= 1
    FI
  OD;

out:
  IF invalid THEN
    ""
  ELSE
    STRING compl := "";
    FOR i FROM stacki DOWNTO 1 DO
      compl +:= stack[i]
    OD;
    compl
  FI
END;

PROC score completion string = (STRING s) LONG INT:
BEGIN
  LONG INT score := 0;
  FOR i FROM LWB s TO UPB s DO
    score *:= 5;
    IF s[i] = ")" THEN
      score +:= 1
    ELIF s[i] = "]" THEN
      score +:= 2
    ELIF s[i] = "}" THEN
      score +:= 3
    ELSE
      score +:= 4
    FI
  OD;
  score
END;

# We have to implement our own sort – yay! #
PROC quicksort = (REF []LONG INT array) VOID:
BEGIN
  PROC swap = (REF []LONG INT array, INT i, j) VOID:
  BEGIN
    LONG INT tmp := array[i];
    array[i] := array[j];
    array[j] := tmp
  END;

  PROC partition = (REF []LONG INT array, INT start, end) INT:
  BEGIN
    LONG INT pivot := array[end];
    INT pivot index := start - 1;
    FOR i FROM start TO end DO
      IF array[i] < pivot THEN
        pivot index +:= 1;
        swap(array, pivot index, i)
      FI
    OD;
    pivot index +:= 1;
    swap(array, pivot index, end);
    pivot index
  END;

  PROC sort = (REF []LONG INT array, INT start, end) VOID:
  BEGIN
    IF start < end AND start >= 0 THEN
      INT pivot index := partition(array, start, end);

      sort(array, start, pivot index - 1);
      sort(array, pivot index + 1, end)
    FI
  END;

  sort(array, LWB array, UPB array)
END;

PROC main = VOID:
BEGIN
  FILE in;

  open(in, "data/data10.txt", stand in channel);
  BOOL finished reading := FALSE;
  on logical file end (in, (REF FILE f) BOOL: finished reading := TRUE);
  on format error (in, (REF FILE f) BOOL: finished reading := TRUE);

  REF []STRING lines := read lines(in, finished reading);
  close(in);

  LONG INT score := 0;
  FOR i FROM LWB lines TO UPB lines DO
    score +:= calc score(lines[i])
  OD;

  printf(($"Part 1: total score = ", g(0)l$, score));

  REF []LONG INT p2 scores := HEAP [UPB lines]LONG INT;
  INT si := 0;
  FOR i FROM LWB lines TO UPB lines DO
    STRING cs := get completion string(lines[i]);
    IF cs /= "" THEN
      LONG INT p2 score := score completion string(cs);
      si +:= 1;
      p2 scores[si] := p2 score;
    FI
  OD;
  p2 scores := p2 scores[:si];
  quicksort(p2 scores);
  LONG INT middle score := p2 scores[(UPB p2 scores + 1) OVER 2];

  printf(($"Part 2: middle score = ", g(0)l$, middle score))
END;

main
