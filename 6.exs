import Enum
input = File.read!("6.input")

defmodule Solve do
  def get_dir(i) do
    [
      # up
      {0, -1},
      # right
      {1, 0},
      # down
      {0, 1},
      # left
      {-1, 0}
    ]
    |> at(i)
  end

  def out_of_bounds?(n, {x, y}) do
    x not in 0..n or y not in 0..n
  end

  def loop?(grid, current, rotations, history, obstacles) do
    rotations = Integer.mod(rotations, 4)
    n = length(grid) - 1
    {x, y} = current
    {xd, yd} = get_dir(rotations)
    next = {x + xd, y + yd}

    cond do
      out_of_bounds?(n, current) ->
        false

      out_of_bounds?(n, next) ->
        false

      {current, rotations} in history ->
        true

      next in obstacles ->
        loop?(
          grid,
          current,
          rotations + 1,
          history ++ [{current, rotations}],
          obstacles
        )

      true ->
        loop?(
          grid,
          next,
          rotations,
          history ++ [{current, rotations}],
          obstacles
        )
    end
  end

  def step(grid, current, rotations, history, obstacles) do
    rotations = Integer.mod(rotations, 4)
    n = length(grid) - 1
    {x, y} = current
    {xd, yd} = get_dir(rotations)
    next = {x + xd, y + yd}
    {next_x, next_y} = next

    history = history ++ [{current, rotations}]

    cond do
      next_x not in 0..n or next_y not in 0..n ->
        %{
          last: next,
          rotations: rotations,
          history: history,
          part1: history |> map(fn {point, _} -> point end) |> uniq |> length
        }

      next in obstacles ->
        step(
          grid,
          current,
          rotations + 1,
          history,
          obstacles
        )

      true ->
        step(
          grid,
          next,
          rotations,
          history,
          obstacles
        )
    end
  end
end

grid =
  input
  |> String.split("\n", trim: true)
  |> map(&String.codepoints(&1))

n = length(grid) - 1

start =
  for(x <- 0..n, y <- 0..n, do: {x, y})
  |> find(fn {x, y} -> grid |> at(y) |> at(x) == "^" end)

obstacles =
  for(x <- 0..n, y <- 0..n, do: {x, y})
  |> filter(fn {x, y} -> grid |> at(y) |> at(x) == "#" end)

%{part1: part1, history: history} = Solve.step(grid, start, 0, [], obstacles)
IO.inspect(part1)

part2 =
  history
  |> map(fn {p, _} -> p end)
  |> uniq
  |> map(&(true == Solve.loop?(grid, start, 0, [], [&1 | obstacles])))
  |> count(&(&1 == true))

IO.inspect(part2)
