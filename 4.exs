import Enum
input = File.read!("4.input")

# 1 2 3
# 4 5 6
# 7 8 9
#
# 1      [0,0]
# 4 2    [1,0] [0,1]
# 7 5 3  [2,0], [1,1] [0,2]
# 8 6    [2,1] [1,2]
# 9      [2,2]
#
# zip(0..0, 0..0)
# zip(0..1, 1..0)
# zip(0..2, 2..0)
# zip(1..2, 2..1)
# zip(2..2, 2..2)

diags = fn grid ->
  n = (grid |> length) - 1
  first_row = 0..n |> map(&{0, &1})
  first_col = 0..(n - 1) |> map(&{&1, 0})
  last_row = 0..n |> map(&{n, &1})
  last_col = 1..n |> map(&{&1, n})

  (((first_row ++ last_col) |> map(fn {a, b} -> zip(a..b, b..a) end)) ++
     ((last_row ++ first_col) |> map(fn {a, b} -> zip(a..b, b..a) end)))
  |> map(&(&1 |> map(fn {y, x} -> grid |> at(x) |> at(y) end)))
end

transpose = fn grid -> grid |> zip |> map(&Tuple.to_list(&1)) end
flat_count = fn x -> x |> List.flatten() |> count(& &1) end

xmas = fn row ->
  row
  |> chunk_every(4, 1, :discard)
  |> map(&(&1 in [~w(X M A S), ~w(S A M X)]))
end

xmas2? = fn {x, y}, grid ->
  case [
    grid |> at(y + 1) |> at(x - 1),
    grid |> at(y + 1) |> at(x + 1),
    grid |> at(y) |> at(x),
    grid |> at(y - 1) |> at(x - 1),
    grid |> at(y - 1) |> at(x + 1)
  ] do
    ~w(M M A S S) -> true
    ~w(S S A M M) -> true
    ~w(M S A M S) -> true
    ~w(S M A S M) -> true
    _ -> false
  end
end

grid =
  input
  |> String.split("\n", trim: true)
  |> map(&String.codepoints(&1))

part1 =
  (grid ++ transpose.(grid) ++ diags.(grid))
  |> map(&xmas.(&1))
  |> flat_count.()

n = (grid |> length) - 2

part2 =
  for(x <- 1..n, y <- 1..n, do: xmas2?.({x, y}, grid))
  |> flat_count.()

{part1, part2} |> IO.inspect()
