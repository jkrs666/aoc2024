import Enum
input = File.read!("10.input")

defmodule Solve do
  def get(grid, {x, y}), do: grid |> at(y) |> at(x)
  def sum_points({x1, y1}, {x2, y2}), do: {x1 + x2, y1 + y2}

  def neighbours(point) do
    [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]
    |> map(fn dir -> sum_points(point, dir) end)
  end

  def out_of_bounds?({x, y}, n) do
    x not in 0..n or y not in 0..n
  end

  def trail(grid, pos) do
    n = count(grid) - 1
    pos_value = get(grid, pos)

    paths =
      neighbours(pos)
      |> reject(fn next ->
        out_of_bounds?(next, n) or
          get(grid, next) - pos_value != 1
      end)

    cond do
      pos_value == 9 ->
        pos

      count(paths) == 0 ->
        {}

      true ->
        paths
        |> map(fn next -> trail(grid, next) end)
        |> List.flatten()
        |> reject(&(&1 == {}))
    end
  end
end

grid =
  input
  |> String.split("\n", trim: true)
  |> map(
    &(&1
      |> String.split("", trim: true)
      |> map(fn x -> String.to_integer(x) end))
  )

n = count(grid) - 1

trailheads =
  for(
    y <- 0..n,
    x <- 0..n,
    do: {x, y}
  )
  |> filter(fn {x, y} -> grid |> at(y) |> at(x) == 0 end)

part1 =
  trailheads
  |> map(&Solve.trail(grid, &1))
  |> map(&(&1 |> uniq |> count()))
  |> sum

part2 =
  trailheads
  |> map(&Solve.trail(grid, &1))
  |> map(&(&1 |> count()))
  |> sum

{part1, part2} |> IO.inspect()
