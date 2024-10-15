defmodule Basic.Parser do
  import NimbleParsec

  defstruct code: %{},
            code_lines: [],
            running: []

  # Tokens básicos: números, operadores, paréntesis, variables
  number = integer(min: 1)

  operator =
    choice([
      string("+"),
      string("-"),
      string("*"),
      string("/")
    ])

  whitespace = ascii_char([?\s, ?\n, ?\r]) |> repeat() |> ignore()

  variable = ascii_string([?A..?Z], 1)

  separator = ascii_char([?:])

  # Definición de una expresión aritmética
  expression =
    choice([
      number,
      variable
    ])
    |> repeat(
      ignore(whitespace)
      |> concat(operator)
      |> ignore(whitespace)
      |> concat(choice([number, variable]))
    )

  # Parseo de la instrucción LET
  let_statement =
    ignore(string("LET"))
    |> ignore(whitespace)
    # Variable a la que se le asigna
    |> concat(variable)
    |> ignore(whitespace)
    # Operador de asignación
    |> ignore(string("="))
    |> ignore(whitespace)
    # Expresión a asignar
    |> concat(expression)

  # Parseo de la instrucción PRINT
  print_statement =
    ignore(string("PRINT"))
    |> ignore(whitespace)
    |> concat(choice([variable, ascii_string([?A..?Z, ?a..?z, ?0..?9, ?\s], min: 1)]))

  # Parseo de la instrucción GOTO
  goto_statement =
    ignore(string("GOTO"))
    |> ignore(whitespace)
    |> concat(number)

  # Parseo de una instrucción cualquiera (LET, PRINT, GOTO)
  statement =
    choice([
      let_statement |> tag(:let),
      print_statement |> tag(:print),
      goto_statement |> tag(:goto)
    ])

  # Parser de expresiones (sin número de línea)
  statements =
    statement
    |> repeat(
      ignore(whitespace)
      |> ignore(separator)
      |> ignore(whitespace)
      |> concat(statement)
    )

  # Parseo de líneas numeradas: número de línea seguido de una instrucción
  line_parser =
    number
    |> ignore(whitespace)
    |> concat(statements)

  # El parser principal reconoce ya sea una línea numerada o una expresión directa
  basic_parser =
    choice([
      # Línea numerada
      line_parser |> tag(:line),
      # Expresión directa
      statements |> tag(:expr)
    ])
    |> ignore(whitespace)
    |> repeat()

  defparsec(:parse, basic_parser)

  def parse_code(code) do
    # Parseamos el código usando el parser
    {:ok, tokens, _, _, _, _} = parse(code)

    # Convertimos el resultado en una lista donde el formato sea {número_de_línea, [instrucciones]}
    Enum.reduce(tokens, %__MODULE__{}, fn
      {:line, [line_number | expr]}, acc ->
        %__MODULE__{
          acc
          | code: Map.put(acc.code, line_number, expr),
            code_lines: [line_number | acc.code_lines]
        }

      {:expr, expr}, acc ->
        %__MODULE__{acc | running: acc.running ++ expr}
    end)
    |> then(&%__MODULE__{&1 | code_lines: Enum.sort(&1.code_lines)})
  end
end
