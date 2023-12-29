with builtins; let
  inherit (import <nixpkgs> { }) lib;
  matrix =
    let
      rawMatrix = (map
        lib.strings.stringToCharacters
        (lib.strings.splitString
          "\n"
          (lib.strings.removeSuffix
            "\n"
            (readFile ./day_3_input.txt))));
    in
    (lib.lists.imap0
      (y: line:
        (lib.lists.imap0
          (x: char:
            { inherit x y char; })
          line))
      rawMatrix);

  pos = x: y: { inherit x y; };
  border = { x, y }: [
    # from top lft
    (pos (x - 1) (y - 1))
    (pos (x) (y - 1))
    (pos (x + 1) (y - 1))

    (pos (x + 1) (y))

    (pos (x + 1) (y + 1))
    (pos (x) (y + 1))
    (pos (x - 1) (y + 1))

    (pos (x - 1) (y))
  ];

  getFromMatrix = { x, y }:
    let
      row =
        if y >= 0 && y < (length matrix) then

          (elemAt
            matrix
            y)
        else
          null;
    in
    if row == null then
      null
    else
      if x >= 0 && x < (length matrix)
      then
        (elemAt
          row
          x)
      else
        null;

  genValidSymbols =
    (lib.lists.unique
      (map
        (x: x.char)
        (filter
          ({ char, ... }: (match "[^0-9.]" char) != null)
          (lib.lists.flatten matrix))));
  validSymbols = lib.traceVal genValidSymbols;
  # symbols =
  #   (filter
  #     ({ char, ... }:
  #       (elem
  #         char
  #         validSymbols))
  #     matrixWithPosAndConent);

  extractNumbers = line:
    let
      start =
        (lib.lists.findFirst
          ({ v, ... }: (match "([0-9])" v.char) != null)
          (null)
          (lib.imap0
            (i: v: { inherit i v; })
            line)).i or null;
    in
    if isNull start then
      [ ]
    else
      let
        lineWithIdx =
          (lib.imap0
            (i: v: { inherit i v; })
            line);
        nonNumberMatcher =
          { v, ... }: (match "([^0-9])" v.char) != null;
        from =
          (lib.lists.sublist
            start
            (length line)
            lineWithIdx);
        end =
          let
            res =
              (lib.lists.findFirst
                nonNumberMatcher
                ({ i = length line; })
                from);
          in
          res.i - 1;
        num =
          (lib.strings.toInt
            (lib.strings.concatStringsSep
              ""
              (map
                ({ char, ... }: char)
                (lib.lists.sublist
                  start
                  ((end - start) + 1)
                  line))));
        rest =
          (lib.lists.sublist
            (end + 1)
            (length line)
            line);
        res = {
          inherit num;
          y = (elemAt line start).y;
          x1 = (elemAt line start).x;
          x2 = (elemAt line end).x;
        };
      in
      [ res ] ++ (extractNumbers rest);

  engineNumbers =
    (lib.flatten
      (lib.imap0
        (i: x: extractNumbers x)
        matrix));

  isDigitConnectedToSymbol = { x, y }:
     (length
      (filter
        ({ x, y }:
          let
            e = lib.traceVal (getFromMatrix (pos x y));
          in
          if e == null then
            false
          else
            (elem e.char validSymbols))
        (border (pos x y)))
    > 0);

  isValid = { y, x1, x2, ... }:
    (length
      (filter
        (x: isDigitConnectedToSymbol (pos x y))
        (lib.range
          x1
          x2))
    > 0);

  validEnigneNumbers =
    (filter
      (x: isValid x)
      engineNumbers);
      # [{ num = 954; x1 = 8; x2 = 10; y = 0; }]);
in
{
  res = foldl' (acc: x: acc + x.num) 0 validEnigneNumbers;
}

# genMatrix 2
# extractNumbers (elemAt matrixWithPosAndConent 0)
