let
  pkgs = import <nixpkgs> { };
in
with builtins; with pkgs; let
  input = lib.lists.forEach
    (lib.splitString
      "\n"
      (lib.strings.removeSuffix
        "\n"
        (readFile ./day_1_input.txt)))
    (x: lib.strings.stringToCharacters x);

  filterDigits = (x:
    let
      y = lib.strings.charToInt x;
      a1 = lib.strings.charToInt "0";
      a2 = lib.strings.charToInt "9";
    in
    a1 <= y && y <= a2);

  filtered = lib.lists.forEach
    input
    (x: filter filterDigits x);


  getFirstAndLastChar = x: [ (head x) (head (lib.lists.reverseList x)) ];

  nums = map
    (x:
      let
        y = getFirstAndLastChar x;
      in
      lib.strings.toInt "${elemAt y 0}${elemAt y 1}")
    filtered;

  output = foldl' (acc: x: acc + x) 0 nums;  
in
output
