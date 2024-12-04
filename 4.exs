import Enum
input = File.read!("4.input")

defmodule Day4 do
  def transpose(grid) do
    grid |> zip |> map(&Tuple.to_list(&1))
  end

  def scan(row) do
    row
    |> chunk_every(4, 1, :discard)
    |> filter(&(&1 in [~w(X M A S), ~w(S A M X)]))
  end

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

  def diags1(length) do
    n = length - 1
    first_row = 0..n |> map(fn i -> {0, i} end)
    last_col = 1..n |> map(fn i -> {i, n} end)

    (first_row ++ last_col)
    |> map(fn {a, b} -> zip(a..b, b..a) end)
  end

  def diags2(length) do
    n = length - 1
    last_row = 0..n |> map(fn i -> {n, i} end)
    first_col = 0..(n - 1) |> map(fn i -> {i, 0} end)

    (last_row ++ first_col)
    |> map(fn {a, b} -> zip(a..b, b..a) end)
  end

  def map_points(points, grid) do
    points
    |> map(fn row ->
      row |> map(fn {y, x} -> grid |> at(x) |> at(y) end)
    end)
  end

  def xmas?({x, y}, grid) do
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
end

grid =
  input
  |> String.split("\n", trim: true)
  |> map(&String.codepoints(&1))

columns = grid |> Day4.transpose()
n = grid |> length

diags1 =
  Day4.diags1(n)
  |> Day4.map_points(grid)

diags2 =
  Day4.diags2(n)
  |> Day4.map_points(grid)

part1 =
  (grid ++ columns ++ diags1 ++ diags2)
  |> map(&Day4.scan(&1))
  |> map(&length(&1))
  |> sum

part2 =
  grid
  |> with_index
  |> drop(1)
  |> drop(-1)
  |> map(fn {row, y} ->
    row
    |> with_index
    |> drop(1)
    |> drop(-1)
    |> map(fn {_, x} -> Day4.xmas?({x, y}, grid) end)
  end)
  |> List.flatten()
  |> count(& &1)

{part1, part2} |> IO.inspect()


