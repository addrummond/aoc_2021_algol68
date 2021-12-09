PROC read integers = (STRING line, STRING separator, REF FLEX []INT numbers) VOID:
BEGIN
  numbers := HEAP FLEX [1:8]INT;
  INT ni := 1;
  INT current number := 0;
  BOOL already got sep := FALSE; # two or more separators in a row? #
  BOOL started := FALSE;         # we've already skipped any initial separators? #

  FOR si FROM LWB line TO UPB line DO
    IF line[si] = separator THEN
      IF NOT already got sep AND started THEN
        already got sep := TRUE;
        IF ni >= UPB numbers THEN # this does need to be >=, not >, to make sure the assignment following the loop isn't OOB #
          REF FLEX[]INT new numbers = HEAP FLEX [1:UPB numbers * 2]INT;
          new numbers[:UPB numbers] := numbers;
          numbers := new numbers
        FI;
        numbers[ni] := current number;
        current number := 0;
        ni +:= 1
      FI
    ELSE
      already got sep := FALSE;
      started := TRUE;
      current number := current number * 10;
      current number := current number + ABS(line[si]) - ABS("0")
    FI
  OD;
  IF UPB line >= 1 THEN
    numbers[ni] := current number
  FI;

  numbers := numbers[:ni]
END;

PROC swap = (REF []INT array, INT i, j) VOID:
BEGIN
  INT tmp := array[i];
  array[i] := array[j];
  array[j] := tmp
END;

# We have to implement our own sort – yay! #
PROC quicksort = (REF []INT array) VOID:
BEGIN
  PROC partition = (REF []INT array, INT start, end) INT:
  BEGIN
    INT pivot := array[end];
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

  PROC sort = (REF []INT array, INT start, end) VOID:
  BEGIN
    IF start < end AND start >= 0 THEN
      INT pivot index := partition(array, start, end);

      sort(array, start, pivot index - 1);
      sort(array, pivot index + 1, end)
    FI
  END;

  sort(array, LWB array, UPB array)
END;

PROC median = (REF []INT array) INT:
BEGIN
  INT tot := 0;
  FOR i FROM LWB array TO UPB array DO
    tot +:= array[i]
  OD;
  ROUND(tot / UPB array)
  #array[(UPB array + 1) OVER 2]#
END;

PROC fuel consumption part 1 = (REF []INT crabs, INT pos) INT:
BEGIN
  INT tot := 0;
  FOR i FROM LWB crabs TO UPB crabs DO
    tot +:= ABS(crabs[i] - pos)
  OD;
  tot
END;

PROC fuel consumption part 2 = (REF []INT crabs, INT pos) INT:
BEGIN
  INT tot := 0;
  FOR i FROM LWB crabs TO UPB crabs DO
    INT distance := ABS(crabs[i] - pos);
    tot +:= (distance * (distance + 1)) OVER 2
  OD;
  tot
END;

PROC part 2 opt pos = (REF []INT crabs, INT start, end) INT:
BEGIN
  INT guess := (start + end) OVER 2;
  INT burn := fuel consumption part 2(crabs, guess);
  IF end <= start THEN
    guess
  ELSE
    INT l burn := fuel consumption part 2(crabs, guess-1);
    INT r burn := fuel consumption part 2(crabs, guess+1);
    IF burn < l burn AND burn < r burn THEN
      guess
    ELIF burn < r burn THEN
      part 2 opt pos(crabs, start, guess - 1)
    ELSE
      part 2 opt pos(crabs, guess + 1, end)
    FI
  FI
END;

PROC main = VOID:
BEGIN
  FILE in;

  open(in, "data/data7.txt", stand in channel);
  STRING line;
  get(in, line);

  REF FLEX []INT crabs := LOC FLEX [1:0]INT;

  read integers(line, ",", crabs);
  close(in);

  # I believe that part 1 reduces to finding the median of the array #
  # (although I have not proved this). #
  quicksort(crabs);
  INT p1 opt pos := median(crabs);
  INT fuel := fuel consumption part 1(crabs, p1 opt pos);

  printf(($"Optimum horizontal position = ", g(0)l$, p1 opt pos));
  printf(($"Fuel consumption = ", g(0)l$, fuel));

  INT p2 opt pos := part 2 opt pos(crabs, LWB crabs, UPB crabs);
  printf(($"P2 Optimum horizontal position = ", g(0)l$, p2 opt pos));
  printf(($"P2 Fuel burn = ", g(0)l$, fuel consumption part 2(crabs, p2 opt pos)))
END;

main
