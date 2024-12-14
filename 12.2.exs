import Enum
input = File.read!("12.test")

defmodule Solve do
  def neighbours(garden, {x, y}) do
    [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]
    |> map(fn {dx, dy} -> {x + dx, y + dy} end)
    |> filter(fn p -> garden[p] == garden[{x, y}] end)
  end

  def traverse(garden, current, history) do
    neighbours =
      neighbours(garden, current)
      |> reject(fn x -> x in history end)

    case neighbours do
      [] ->
        [current | history] |> uniq

      _ ->
        neighbours
        |> map(fn x -> traverse(garden, x, [current | history]) end)
        |> List.flatten()
        |> uniq
    end
  end

  def links(area, {x1, y1}) do
    area
    |> filter(fn {x2, y2} ->
      (abs(x1 - x2) == 1 and y1 == y2) or
        (abs(y1 - y2) == 1 and x1 == x2)
    end)
    |> count
  end

  def links2(garden, p) do
    ns = neighbours(garden, p)
      case ns do
      [] -> 
    |> map(fn n -> {{p, n}, garden[p]} end)
    |> dbg(charlists: :as_lists)
  end

  def calculate_price(area) do
    perimeter =
      area
      |> map(fn p ->
        links(area, p)
      end)
      |> map(fn score -> 4 - score end)
      |> sum

    perimeter * count(area)
  end
end

grid =
  input
  |> String.split("\n", trim: true)
  |> map(&(&1 |> String.codepoints()))

n = count(grid) - 1

garden =
  for(y <- 0..n, x <- 0..n, do: {{x, y}, grid |> at(y) |> at(x)})
  |> Map.new()
  |> dbg

# for(y <- 0..n, x <- 0..n, do: {x, y})
# |> map(&(Solve.traverse(garden, &1, []) |> sort))
# |> uniq
# |> Task.async_stream(&Solve.calculate_price(&1))
# |> map(fn {:ok, res} -> res end)
# |> sum

links =
  for(y <- 0..n, x <- 0..n, do: {x, y})
  |> map(&Solve.links2(garden, &1))
  |> dbg

#
# {part1, part2} |> IO.inspect()
