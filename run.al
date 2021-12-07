BEGIN
  FILE in;
  STRING s;

  open(in, "data.txt", stand in channel);
  BOOL finished reading := FALSE;
  on logical file end (in, (REF FILE f) BOOL: finished reading := TRUE);

  INT last measurement := -1;
  INT count := 0;

  WHILE
    INT value;
    get(in,(value, new line));
    NOT finished reading
  DO 
    IF last measurement /= -1 THEN
      IF value > last measurement THEN
        count := count + 1
      FI
    FI;

    last measurement := value
  OD;
  close(in);

  printf(($ "The number of increaes: ", 5zd$, count));
  print(newline)
END

