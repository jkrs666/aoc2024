import Enum
input = File.read!("14.input")

defmodule Solve do
  def add_points({x1, y1}, {x2, y2}) do
    {x1 + x2, y1 + y2}
  end

  def mul_point({x, y}, n) do
    {x * n, y * n}
  end

  def part1(robots, width, height, t) do
    mid_width = (width - 1) / 2
    mid_height = (height - 1) / 2

    robots
    |> map(fn [x, y, vx, vy] ->
      {Integer.mod(vx * t + x, width), Integer.mod(vy * t + y, height)}
    end)
    |> frequencies
    |> reject(fn {{x, y}, _c} -> x == mid_width or y == mid_height end)
    |> group_by(fn {{x, y}, _c} -> {x < mid_width, y < mid_height} end)
    |> Map.values()
    |> map(fn list -> list |> map(fn {{_x, _y}, c} -> c end) |> sum end)
    |> product
    |> dbg
  end

  def part2(robots, width, height, t) do
    points =
      robots
      |> map(fn [x, y, vx, vy] ->
        {Integer.mod(vx * t + x, width), Integer.mod(vy * t + y, height)}
      end)

    for y <- 0..(height - 1) do
      for x <- 0..(width - 1) do
        if {x, y} in points do
          "*"
        else
          "."
        end
      end
      |> join()
    end
    |> join("\n")
    |> IO.puts()
  end
end

robots =
  input
  |> String.split("\n", trim: true)
  |> map(
    &(Regex.scan(~r/([-]?\d+)+/, &1, capture: :all_but_first)
      |> List.flatten()
      |> map(fn i -> String.to_integer(i) end))
  )

# Solve.part1(robots, 11, 7, 100)
# Solve.part2(robots, 11, 7, t)

Solve.part1(robots, 101, 103, 100)
Solve.part2(robots, 101, 103, 7858)
