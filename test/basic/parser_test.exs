defmodule Basic.ParserTest do
  use ExUnit.Case

  @path_names Path.wildcard("test/code/*.bas")

  describe "tokenize" do
    for path_name <- @path_names do
      filename = Path.basename(path_name)
      [_number, name] = String.split(Path.rootname(filename), "_", parts: 2)
      test "#{name}" do
        code = File.read!(unquote(path_name))
        {expected, _} = Code.eval_file(Path.rootname(unquote(path_name)) <> ".token.exs")
        assert expected == Basic.Parser.parse(code)
      end
    end
  end

  describe "parse" do
    for path_name <- @path_names do
      filename = Path.basename(path_name)
      [_number, name] = String.split(Path.rootname(filename), "_", parts: 2)
      test "#{name}" do
        code = File.read!(unquote(path_name))
        {expected, _} = Code.eval_file(Path.rootname(unquote(path_name)) <> ".parse.exs")
        assert expected == Basic.Parser.parse_code(code)
      end
    end
  end
end
