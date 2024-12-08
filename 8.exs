import Enum
input = File.read!("8.input")

defmodule Solve do
  def pairs(list) do
    n = count(list) - 1

    for(
      i <- 0..(n - 1),
      j <- (i + 1)..n,
      do: [at(list, i), at(list, j)]
    )
  end

  def antinodes([{x1, y1}, {x2, y2}], n) do
    dx = x1 - x2
    dy = y1 - y2

    [
      {x1 + dx, y1 + dy},
      {x2 - dx, y2 - dy}
    ]
    |> reject(&out_of_bounds?(&1, n))
  end

  def antinodes2([{x1, y1}, {x2, y2}], n) do
    dx = x1 - x2
    dy = y1 - y2

    travel({x1, y1}, {dx, dy}, n, []) ++
      travel({x2, y2}, {-dx, -dy}, n, [])
  end

  def travel(current, diff, n, history) do
    {x, y} = current
    {dx, dy} = diff
    next = {x + dx, y + dy}

    case out_of_bounds?(next, n) do
      true -> [current | history]
      false -> travel(next, diff, n, [current | history])
    end
  end

  def out_of_bounds?({x, y}, n) do
    x not in 0..n or y not in 0..n
  end

  def solve(freqs, n, antinodes_fn) do
    freqs
    |> map(fn {_freq, antennas} ->
      antennas
      |> pairs()
      |> map(fn [{p1, _}, {p2, _}] ->
        [p1, p2]
        |> antinodes_fn.(n)
      end)
    end)
    |> List.flatten()
    |> uniq
    |> count
  end

  def part1(freqs, n), do: solve(freqs, n, &antinodes/2)
  def part2(freqs, n), do: solve(freqs, n, &antinodes2/2)
end

grid =
  input
  |> String.split("\n", trim: true)
  |> map(&String.codepoints(&1))

n = count(grid) - 1

freqs =
  for(
    y <- 0..n,
    x <- 0..n,
    do: {{x, y}, grid |> at(y) |> at(x)}
  )
  |> filter(fn {_point, c} -> c != "." end)
  |> group_by(fn {_point, freq} -> freq end)

{Solve.part1(freqs, n), Solve.part2(freqs, n)} |> IO.inspect()
