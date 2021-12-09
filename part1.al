FILE in;

open(in, "data/data1.txt", stand in channel);
BOOL finished reading := FALSE;
on logical file end (in, (REF FILE f) BOOL: finished reading := TRUE);

INT last measurement := -1;
INT count := 0;

WHILE
  INT value;
  get(in, (value, new line));
  NOT finished reading
DO
  IF last measurement /= -1 AND value > last measurement THEN
    count +:= 1
  FI;

  last measurement := value
OD;

close(in);

printf(($"The number of increases: ", g(0)l$, count))

