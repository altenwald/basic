defmodule Basic.ParserTest do
  use ExUnit.Case
  doctest Basic

  describe "tokenize" do
    test "basic BASIC code" do
      code = """
      10 LET X = 5 + 3
      20 PRINT X
      30 GOTO 10
      """

      assert {:ok,
              [
                line: [10, {:let, ["X", 5, "+", 3]}],
                line: [20, {:print, ["X"]}],
                line: [30, {:goto, ~c"\n"}]
              ], "", %{}, {4, 39}, 39} == Basic.Parser.parse(code)
    end

    test "lines and expressions" do
      code = """
      10 LET X = 5 + 3
      PRINT X
      30 GOTO 10
      """

      assert {:ok,
              [
                line: [10, {:let, ["X", 5, "+", 3]}],
                expr: [print: ["X"]],
                line: [30, {:goto, ~c"\n"}]
              ], "", %{}, {4, 36}, 36} == Basic.Parser.parse(code)
    end

    test "multiple commands per line" do
      code = """
      10 LET X = 5 + 3: PRINT X
      15 GOTO 10
      """

      assert {:ok,
              [
                line: [10, {:let, ["X", 5, "+", 3]}, {:print, ["X"]}],
                line: [15, {:goto, ~c"\n"}]
              ], "", %{}, {3, 37}, 37} == Basic.Parser.parse(code)
    end
  end

  describe "parse" do
    test "parse basic BASIC code" do
      code = """
      10 LET X = 5 + 3
      20 PRINT X
      30 GOTO 10
      """

      assert %Basic.Parser{
               code: %{10 => [let: ["X", 5, "+", 3]], 20 => [print: ["X"]], 30 => [goto: ~c"\n"]},
               code_lines: [10, 20, 30]
             } == Basic.Parser.parse_code(code)
    end

    test "lines and expressions" do
      code = """
      10 LET X = 5 + 3
      PRINT X
      30 GOTO 10
      """

      assert %Basic.Parser{
               code: %{10 => [let: ["X", 5, "+", 3]], 30 => [goto: ~c"\n"]},
               code_lines: [10, 30],
               running: [print: ["X"]]
             } == Basic.Parser.parse_code(code)
    end

    test "multiple commands per line" do
      code = """
      10 LET X = 5 + 3: PRINT X
      15 GOTO 10
      """

      assert %Basic.Parser{
               code: %{10 => [let: ["X", 5, "+", 3], print: ["X"]], 15 => [goto: ~c"\n"]},
               code_lines: [10, 15]
             } == Basic.Parser.parse_code(code)
    end
  end
end
