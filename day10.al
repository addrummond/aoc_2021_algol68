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

PROC calc score = (STRING line) INT:
BEGIN
  [UPB line]CHAR stack;
  INT stacki := 0;

  INT score := 0;

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
      IF line[i] /= stack[stacki] THEN
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

PROC main = VOID:
BEGIN
  FILE in;

  open(in, "data/data10.txt", stand in channel);
  BOOL finished reading := FALSE;
  on logical file end (in, (REF FILE f) BOOL: finished reading := TRUE);
  on format error (in, (REF FILE f) BOOL: finished reading := TRUE);

  REF []STRING lines := read lines(in, finished reading);
  close(in);

  INT score := 0;
  FOR i FROM LWB lines TO UPB lines DO
    score +:= calc score(lines[i])
  OD;

  printf(($"Part 1: total score = ", g(0)l$, score))
END;

main