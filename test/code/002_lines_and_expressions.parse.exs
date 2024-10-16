%Basic.Parser{
  code: %{
    10 => [let: ["X", 5, "+", 3]],
    30 => [goto: ~c"\n"]
  },
  code_lines: [10, 30],
  running: [print: ["X"]]
}
