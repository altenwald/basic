%Basic.Parser{
  code: %{
    10 => [let: ["X", 5, "+", 3]],
    20 => [print: ["X"]],
    30 => [goto: ~c"\n"]
  },
  code_lines: [10, 20, 30]
}
