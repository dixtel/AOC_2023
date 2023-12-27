let
  pkgs = import <nixpkgs> { };
  inherit (pkgs) lib;
in
with builtins; let
  input =
    lib.strings.splitString
      "\n"
      (lib.strings.removeSuffix
        "\n"
        (readFile ./day_2_input.txt));

  gameParser = line:
    let
      gameNum =
        lib.strings.toInt
          (elemAt
            (match ''Game ([0-9]+):.*'' line)
            0);
      setsRaw =
        lib.strings.removePrefix
          "Game ${gameNum}: "
          line;
      sets =
        lib.strings.splitString ";" line;
    in
    {
      id = gameNum;
      sets = sets;
    };

  games =
    lib.lists.forEach
      input
      gameParser;

  getCount = set: color:
    lib.strings.toInt
      (elemAt
        (
          let res =
            (match
              ".*? ([0-9]+) ${color}.*"
              set); in if res == null then [ "0" ] else res
        )
        0);

  setsHandler = { id, sets }:
    let
      red =
        lib.lists.forEach
          sets
          (set: getCount set "red");
      blue =
        lib.lists.forEach
          sets
          (set: getCount set "blue");
      green =
        lib.lists.forEach
          sets
          (set: getCount set "green");
    in
    {
      inherit id;
      r = elemAt (lib.lists.sort (x: y: x > y) red) 0;
      b = elemAt (lib.lists.sort (x: y: x > y) blue) 0;
      g = elemAt (lib.lists.sort (x: y: x > y) green) 0;
    };

  gameResults = lib.lists.forEach
    games
    setsHandler;

  result =
    foldl'
      (acc: x: acc + (with x; r * g * b))
      0
      gameResults;
in
result
