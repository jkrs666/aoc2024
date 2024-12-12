import Enum
input = File.read!("12.test2")

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

area =
  Solve.traverse(garden, {0, 0}, [])

perimeter =
  area
  |> map(fn p ->
    Solve.links(area, p)
  end)
  |> map(fn score -> 4 - score end)
  |> sum

perimeter * count(area)

for(y <- 0..n, x <- 0..n, do: {x, y})
|> map(&(Solve.traverse(garden, &1, []) |> sort))
|> uniq
|> Task.async_stream(&Solve.calculate_price(&1))
|> map(fn {:ok, res} -> res end)
|> sum
|> dbg(charlists: :as_lists)

#
# {part1, part2} |> IO.inspect()
