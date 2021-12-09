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

PROC swap = (REF FLEX []INT array, INT i, j) VOID:
BEGIN
  INT tmp := array[i];
  array[i] := array[j];
  array[j] := tmp
END;

# We have to implement our own sort – yay! #
PROC quicksort = (REF FLEX []INT array) VOID:
BEGIN
  PROC partition = (REF FLEX []INT array, INT start, end) INT:
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
    swap (array, pivot index, end);
    pivot index
  END;

  PROC sort = (REF FLEX []INT array, INT start, end) VOID:
  BEGIN
    IF start < end AND start >= 0 THEN
      INT pivot index := partition(array, start, end);

      sort(array, start, pivot index - 1);
      sort(array, pivot index + 1, end)
    FI
  END;

  sort(array, LWB array, UPB array)
END;

# I believe that this problem reduces to finding the median of the array #
# (although I have not proved this). #
PROC median = (REF FLEX []INT array) INT:
BEGIN
  array[(UPB array + 1) OVER 2]
END;

PROC fuel consumption = (REF FLEX []INT crabs, INT pos) INT:
BEGIN
  INT tot := 0;
  FOR i FROM LWB crabs TO UPB crabs DO
    tot +:= ABS(crabs[i] - pos)
  OD;
  tot
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

  quicksort(crabs);

  INT opt pos := median(crabs);
  INT fuel := fuel consumption(crabs, opt pos);

  printf(($"Optimum horizontal position = ", g(0)l$, opt pos));
  printf(($"Fuel consumption = ", g(0)l$, fuel))
END;

main
