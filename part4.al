INT card dim = 5;

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

PROC get bingo state = (REF FILE in, REF BOOL finished reading, REF FLEX []INT numbers, REF FLEX []REF [,]INT cards) VOID:
BEGIN
  # parse states #
  INT get numbers = 1;
  INT skip first blank = 2;
  INT in row = 3;

  INT state := get numbers;

  REF [,]INT current card := HEAP [card dim, card dim]INT;
  INT card row := 1;
  INT card col := 1;
  INT card index := 1;

  cards := HEAP FLEX [1:8]REF [,]INT;
  numbers := LOC FLEX [1:0]INT;

  WHILE
    NOT finished reading
  DO
    STRING line;
    get(in, (line, newline));

    CASE state IN
      # get numbers #
      BEGIN
        read integers(line, ",", numbers);
        state := skip first blank
      END,
      # skip first blank #
      state := in row,
      # in row #
      IF line = "" THEN
        IF card index > UPB cards THEN
          REF FLEX []REF [,]INT new cards = HEAP FLEX [1:2 * UPB cards]REF [,]INT;
          new cards[:UPB cards] := cards;
          cards := new cards
        FI;
        cards[card index] := current card;
        current card := HEAP [card dim, card dim]INT;
        card index := card index + 1;
        card row := 1;
        card col := 1
      ELSE
        FLEX [1:0]INT row numbers;
        read integers(line, " ", row numbers);
        current card[card row,] := row numbers;
        card row := card row + 1
      FI
    ESAC
  OD;

  cards[card index] := current card;
  cards := cards[:card index]
END;

PROC play bingo = (REF FLEX []INT numbers, REF FLEX []REF [,]INT cards) INT:
BEGIN
  REF []INT card scores = HEAP [UPB cards]INT;
  FOR ci FROM LWB cards TO UPB cards DO
    card scores[ci] := 0;
    FOR r FROM 1 TO card dim DO
      FOR c FROM 1 TO card dim DO
        card scores[ci] := card scores[ci] + cards[ci][r,c]
      OD
    OD
  OD;

  REF [,]INT row marks = HEAP [UPB cards,card dim]INT;
  REF [,]INT col marks = HEAP [UPB cards,card dim]INT;
  FOR ci FROM LWB cards TO UPB cards DO
    FOR i FROM 1 TO card dim DO
      row marks[ci,i] := 0;
      col marks[ci,i] := 0
    OD
  OD;

  INT winning card := -1;
  INT n;

  FOR i FROM LWB numbers TO UPB numbers DO
    n := numbers[i];

    FOR ci FROM LWB cards TO UPB cards DO
      FOR r FROM 1 TO card dim DO
        FOR c FROM 1 TO card dim DO
          IF cards[ci][r,c] = n THEN
            card scores[ci] := card scores[ci] - n;
            row marks[ci,r] := row marks[ci,r] + 1;
            col marks[ci,c] := col marks[ci,c] + 1;
            IF row marks[ci,r] = card dim OR col marks[ci, c] = card dim THEN
              winning card := ci;
              GO TO out
            FI
          FI
        OD
      OD
    OD
  OD;

out:
  IF winning card = -1 THEN
    0
  ELSE
    card scores[winning card] * n
  FI
END;

PROC main = VOID:
BEGIN
  FILE in;

  open(in, "data4.txt", stand in channel);
  BOOL finished reading := FALSE;
  on logical file end (in, (REF FILE f) BOOL: finished reading := TRUE);

  REF FLEX []INT numbers := LOC FLEX [1:0]INT;
  REF FLEX []REF [,]INT cards := LOC FLEX [1:0]REF [,]INT;

  get bingo state(in, finished reading, numbers, cards);
  close(in);

  printf(($"Winning score = ", 10zdl$, play bingo(numbers, cards)))
END;

main
