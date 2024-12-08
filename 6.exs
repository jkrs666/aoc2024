import Enum
input = File.read!("6.input")

defmodule Solve do
  def get_dir(i) do
    # up right down left
    [{0, -1}, {1, 0}, {0, 1}, {-1, 0}]
    |> at(i)
  end

  def out_of_bounds?(n, {x, y}) do
    x not in 0..n or y not in 0..n
  end

  def step(edge, current, rotations, history, obstacles) do
    rotations = Integer.mod(rotations, 4)
    {x, y} = current
    {xd, yd} = get_dir(rotations)
    next = {x + xd, y + yd}

    cond do
      out_of_bounds?(edge, next) ->
        %{
          loop: false,
          history: [{current, rotations} | history]
        }

      {current, rotations} in history ->
        %{loop: true}

      next in obstacles ->
        step(
          edge,
          current,
          rotations + 1,
          [{current, rotations} | history],
          obstacles
        )

      true ->
        step(
          edge,
          next,
          rotations,
          [{current, rotations} | history],
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
points = for(x <- 0..n, y <- 0..n, do: {x, y})

start =
  points
  |> find(fn {x, y} -> grid |> at(y) |> at(x) == "^" end)

obstacles =
  points
  |> filter(fn {x, y} -> grid |> at(y) |> at(x) == "#" end)

%{history: history} = Solve.step(n, start, 0, [], obstacles)

part1 =
  history
  |> map(fn {point, _} -> point end)
  |> uniq
  |> count

part2 =
  history
  |> map(fn {p, _} -> p end)
  |> uniq
  |> Task.async_stream(&Solve.step(n, start, 0, [], [&1 | obstacles]))
  |> count(fn {:ok, %{loop: loop}} -> loop == true end)

{part1, part2} |> IO.inspect()

# {4967, 1789}
#
# real    0m58.083s
# user    11m16.741s
# sys     0m3.661s
