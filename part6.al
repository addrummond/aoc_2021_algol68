INT n days = 80;
INT start value = 6;
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
        ni := ni + 1
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

PROC simulate = (REF FLEX []INT fish) INT:
BEGIN
  FOR day FROM 1 TO n days DO
    INT n new fish := 0;
    FOR fi FROM LWB fish TO UPB fish DO
      fish[fi] := fish[fi] - 1;
      IF fish[fi] < 0 THEN
        fish[fi] := start value;
        n new fish := n new fish + 1
      FI
    OD;

    REF FLEX []INT new fish = HEAP FLEX [UPB fish + n new fish]INT;
    new fish[:UPB fish] := fish;
    FOR fi FROM UPB fish + 1 TO UPB new fish DO
      new fish[fi] := start value + new fish extra
    OD;
    fish := new fish
  OD;

  UPB fish
END;

PROC main = VOID:
BEGIN
  FILE in;

  open(in, "data6.txt", stand in channel);
  STRING line;
  get(in, line);

  REF FLEX []INT fish := LOC FLEX [1:0]INT;

  read integers(line, ",", fish);
  close(in);

  INT n fish := simulate(fish);

  printf(($"Number of fish = ", 10zdl$, n fish))
END;

main
