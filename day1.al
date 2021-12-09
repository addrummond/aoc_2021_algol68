PROC read numbers = (REF FLEX []INT array) VOID:
BEGIN
  FILE in;

  open(in, "data/data1.txt", stand in channel);
  BOOL finished reading := FALSE;
  on logical file end (in, (REF FILE f) BOOL: finished reading := TRUE);

  array := HEAP FLEX [1:8]INT;

  INT n := 0;
  WHILE
    INT value;
    get(in, (value, new line));
    NOT finished reading
  DO
    n +:= 1;
    IF n > UPB array THEN
      REF FLEX []INT new array = HEAP FLEX [1:2*UPB array]INT;
      new array[:UPB array] := array;
      array := new array
    FI;
    array[n] := value
  OD;

  close(in);

  array := array[:n]
END;

PROC part 1 increases = (REF FLEX []INT array) INT:
BEGIN
  FILE in;

  INT last measurement := -1;
  INT count := 0;

  FOR i FROM LWB array TO UPB array DO
    INT value := array[i];
    IF last measurement /= -1 AND value > last measurement THEN
      count +:= 1
    FI;

    last measurement := value
  OD;

  count
END;

PROC part 2 increases = (REF FLEX []INT array) INT:
BEGIN
  FILE in;

  INT last measurement := -1;
  INT count := 0;

  FOR i FROM LWB array TO UPB array - 2 DO
    INT v1 := array[i];
    INT v2 := array[i+1];
    INT v3 := array[i+2];

    INT value := v1 + v2 + v3;

    IF last measurement /= -1 AND value > last measurement THEN
      count +:= 1
    FI;

    last measurement := value
  OD;

  count
END;

PROC main = VOID:
BEGIN
  REF FLEX []INT array := LOC FLEX [1:0]INT;
  read numbers(array);

  INT p1 increases := part 1 increases(array);
  printf(($"Part 1: the number of increases = ", g(0)l$, p1 increases));

  INT p2 increases := part 2 increases(array);
  printf(($"Part 2: the number of increases = ", g(0)l$, p2 increases))
END;

main

