INT n days = 80;
INT part 2 n days = 256;
INT start value = 7; # we offset the counters by +1 for more convenient array indexing #
INT new fish extra = 2;

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

PROC simulate = (REF FLEX []INT fish, INT n days) INT:
BEGIN
  [start value + new fish extra]INT nfish;
  FOR i FROM LWB nfish TO UPB nfish DO
    nfish[i] := 0
  OD;
  FOR i FROM LWB fish TO UPB fish DO
    nfish[fish[i]+1] +:= 1
  OD;

  FOR day FROM 1 TO n days DO
    INT n new fish := nfish[1];
    FOR i FROM 1 TO UPB nfish - 1 DO
      nfish[i] := nfish[i + 1]
    OD;
    nfish[start value + new fish extra] := n new fish;
    nfish[start value] +:= n new fish
  OD;

  INT tot := 0;
  FOR i FROM LWB nfish TO UPB nfish DO
    tot +:= nfish[i]
  OD;

  tot
END;

PROC main = VOID:
BEGIN
  FILE in;

  open(in, "data/data6.txt", stand in channel);
  STRING line;
  get(in, line);

  REF FLEX []INT fish := LOC FLEX [1:0]INT;

  read integers(line, ",", fish);
  close(in);

  INT n fish := simulate(fish, n days);
  INT part 2 n fish := simulate(fish, part 2 n days);

  printf(($"Part 1: number of fish after ", g(0), " days = ", g(0)l$, n days, n fish));
  printf(($"Part 2: number of fish after ", g(0), " days = ", g(0)l$, part 2 n days, part 2 n fish))
END;

main
