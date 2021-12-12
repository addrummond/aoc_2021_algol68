
PROC part 1 = INT:
BEGIN
  FILE in;

  open(in, "data/data2.txt", stand in channel);
  BOOL finished reading := FALSE;
  on logical file end (in, (REF FILE f) BOOL: finished reading := TRUE);

  INT horizontal position := 0;
  INT depth := 0;

  WHILE
    INT direction;
    INT n;
    getf(in, ($ c("forward", "down", "up")x, dl $, direction, n));
    NOT finished reading
  DO
    CASE direction IN
      horizontal position := horizontal position + n,
      depth := depth + n,
      depth := depth - n
    ESAC
  OD;

  close(in);

  horizontal position * depth
END;

PROC part 2 = INT:
BEGIN
  FILE in;

  open(in, "data/data2.txt", stand in channel);
  BOOL finished reading := FALSE;
  on logical file end (in, (REF FILE f) BOOL: finished reading := TRUE);

  INT horizontal position := 0;
  INT depth := 0;
  INT aim := 0;

  WHILE
    INT direction;
    INT n;
    getf(in, ($ c("forward", "down", "up")x, dl $, direction, n));
    NOT finished reading
  DO
    CASE direction IN
      (horizontal position +:= n, depth +:= aim * n),
      aim +:= n,
      aim -:= n
    ESAC
  OD;

  close(in);

  horizontal position * depth
END;

PROC main = VOID:
BEGIN
  printf(($"Part1: horizontal position * depth = ", g(0)l$, part 1));
  printf(($"Part2: horizontal position * depth = ", g(0)l$, part 2))
END;

main
