import Enum
import Bitwise

combo_operand = fn
  4, a, _b, _c -> a
  5, _a, b, _c -> b
  6, _a, _b, c -> c
  x, _a, _b, _c -> x
end

adv = fn {i, a, b, c, program, output} ->
  d =
    program
    |> at(i + 1)
    |> combo_operand.(a, b, c)

  a = a >>> d

  {i + 2, a, b, c, program, output}
end

bxl = fn {i, a, b, c, program, output} ->
  b =
    program
    |> at(i + 1)
    |> bxor(b)

  {i + 2, a, b, c, program, output}
end

bst = fn {i, a, b, c, program, output} ->
  b =
    program
    |> at(i + 1)
    |> combo_operand.(a, b, c)
    |> band(7)

  {i + 2, a, b, c, program, output}
end

jnz = fn
  {i, 0, b, c, program, output} ->
    {i + 2, 0, b, c, program, output}

  {i, a, b, c, program, output} ->
    i =
      program
      |> at(i + 1)

    {i, a, b, c, program, output}
end

bxc = fn {i, a, b, c, program, output} ->
  b = bxor(b, c)

  {i + 2, a, b, c, program, output}
end

out = fn {i, a, b, c, program, output} ->
  o =
    program
    |> at(i + 1)
    |> combo_operand.(a, b, c)
    |> band(7)

  {i + 2, a, b, c, program, [o | output]}
end

bdv = fn {i, a, b, c, program, output} ->
  d =
    program
    |> at(i + 1)
    |> combo_operand.(a, b, c)

  b = a >>> d

  {i + 2, a, b, c, program, output}
end

cdv = fn {i, a, b, c, program, output} ->
  d =
    program
    |> at(i + 1)
    |> combo_operand.(a, b, c)

  c = a >>> d

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

# test1
# program = [0, 1, 5, 4, 3, 0]
# a = 729
# b = 0
# c = 0

# part1 = 3,6,3,7,0,7,0,3,0

a = 51_064_159
b = 0
c = 0
program = [2, 4, 1, 5, 7, 5, 1, 6, 0, 3, 4, 6, 5, 5, 3, 0]

part1 =
  0..72
  |> reduce_while({0, a, b, c, program, []}, fn n, {i, a, b, c, program, output} ->
    cond do
      i > count(program) - 1 ->
        # n |> IO.puts()
        {:halt, {i, a, b, c, program, output}}

      true ->
        {:cont, instructions.(at(program, i)).({i, a, b, c, program, output})}
    end
  end)
  |> then(fn {i, a, b, c, program, output} -> output end)
  |> reverse
  |> join(",")
  |> IO.inspect()

#######################

# test2

program = [0, 1, 5, 4, 3, 0]
program = [0, 3, 5, 4, 3, 0]

test = fn n ->
  result =
    0..999_999
    |> reduce_while({0, n, b, c, program, []}, fn _, {i, a, b, c, program, output} ->
      cond do
        program |> take(count(output)) != output |> reverse ->
          {:halt, {:skip, n, reverse(output)}}

        i > count(program) - 1 ->
          # {:halt, {i, a, b, c, program, output |> reverse}}
          {:halt, output |> reverse}

        # program == reverse(output) ->
        # {:halt, {:ayy, n, program, reverse(output)}}

        true ->
          {:cont, instructions.(at(program, i)).({i, a, b, c, program, output})}
      end
    end)

  # result |> dbg(charlists: :as_lists)
  result == program
end

0_000_000..1_000_000
|> Task.async_stream(fn n -> {test.(n), n} end)
|> find(fn {:ok, {t, _}} -> t == true end)
|> dbg
