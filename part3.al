FILE in;

open(in, "data3.txt", stand in channel);
BOOL finished reading := FALSE;
on logical file end (in, (REF FILE f) BOOL: finished reading := TRUE);

INT number of digits = 12;

[1:number of digits] INT ones;
FOR i FROM 1 TO number of digits DO
  ones[i] := 0
OD;

WHILE
  [1:number of digits] INT digits;
  getf(in, ($ n(number of digits)(c("0", "1"))l $, digits));
  NOT finished reading
DO
  FOR d FROM 1 TO number of digits DO
    CASE digits[d] IN
      ones[d] := ones[d] - 1,
      ones[d] := ones[d] + 1
    ESAC
  OD;
OD;

INT gamma := 0;
INT epsilon := 0;

FOR d FROM 1 TO number of digits DO
  IF ones[d] > 0 THEN
    gamma := gamma + ABS(BIN(1) SHL (number of digits - d))
  ELSE
    epsilon := epsilon + ABS(BIN(1) SHL (number of digits - d))
  FI
OD;

printf(($"Power consumption = ", 10zdl$, gamma * epsilon))
