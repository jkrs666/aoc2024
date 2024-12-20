import Enum
import Integer
import Bitwise

literal_operand = fn x -> x end

combo_operand = fn
  4, a, _b, _c -> a
  5, _a, b, _c -> b
  6, _a, _b, c -> c
  x, _a, _b, _c -> x
end

adv = fn {i, a, b, c, program, output} ->
  denominator =
    2 **
      (program
       |> at(i + 1)
       |> combo_operand.(a, b, c))

  a = a |> floor_div(denominator)

  {i + 2, a, b, c, program, output}
end

bxl = fn {i, a, b, c, program, output} ->
  b =
    program
    |> at(i + 1)
    |> literal_operand.()
    |> bxor(b)

  {i + 2, a, b, c, program, output}
end

bst = fn {i, a, b, c, program, output} ->
  b =
    program
    |> at(i + 1)
    |> combo_operand.(a, b, c)
    |> mod(8)

  {i + 2, a, b, c, program, output}
end

jnz = fn
  {i, 0, b, c, program, output} ->
    {i, 0, b, c, program, output}

  {i, a, b, c, program, output} ->
    i =
      program
      |> at(i + 1)
      |> literal_operand.()

    {i, a, b, c, program, output}
end

bxc = fn {i, a, b, c, program, output} ->
  c = bxor(b, c)

  {i + 2, a, b, c, program, output}
end

out = fn {i, a, b, c, program, output} ->
  o =
    program
    |> at(i + 1)
    |> combo_operand.(a, b, c)
    |> mod(8)

  {i + 2, a, b, c, program, [o | output]}
end

bdv = fn {i, a, b, c, program, output} ->
  denominator =
    2 **
      (program
       |> at(i + 1)
       |> combo_operand.(a, b, c))

  b = a |> floor_div(denominator)

  {i + 2, a, b, c, program, output}
end

cdv = fn {i, a, b, c, program, output} ->
  denominator =
    2 **
      (program
       |> at(i + 1)
       |> combo_operand.(a, b, c))

  c = a |> floor_div(denominator)

  {i + 2, a, b, c, program, output}
end

instructions =
  fn
    0 -> adv
    1 -> bxl
    2 -> bst
    3 -> jnz
    4 -> bxc
    5 -> out
    6 -> bdv
    7 -> cdv
  end

program = [0, 1, 5, 4, 3, 0]
a = 729
b = 0
c = 0

# input = %{
#  registers: { 51064159, 0, 0},
#  program:  [ 2,4,1,5,7,5,1,6,0,3,4,6,5,5,3,0 ]
# }

program = [0, 1, 5, 4, 3, 0]
a = 2024
b = 0
c = 0

# program = [2, 6]
# a = 0
# b = 0
# c = 9
#
# program = [5, 0, 5, 1, 5, 4]
# a = 10
# b = 0
# c = 0

0..10
|> reduce_while({0, a, b, c, program, []}, fn _, {i, a, b, c, program, output} ->
  if i < count(program) do
    {:cont, instructions.(at(program, i)).({i, a, b, c, program, output}) |> dbg}
  else
    {:halt, {i, a, b, c, program, output}}
  end
end)
|> then(fn {i, a, b, c, program, output} -> output end)
|> reverse
|> join(",")
|> dbg
