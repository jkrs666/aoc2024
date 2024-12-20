import Enum
input = File.read!("16.test2")
input = File.read!("16.input")

defmodule Globals do
  use Agent

  def start_link() do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def state() do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def put(key, value) do
    Agent.update(
      __MODULE__,
      fn state ->
        Map.put(state, key, value)
      end
    )
  end

  def get(key) do
    Agent.get(
      __MODULE__,
      fn state ->
        Map.get(state, key)
      end
    )
  end
end

defmodule Solve do
  def add({x, y}, {dx, dy}) do
    {x + dx, y + dy}
  end

  def dirs(i) do
    [
      # left
      {-1, 0},
      # up
      {0, -1},
      # right
      {1, 0},
      # down
      {0, 1}
    ]
    |> at(i)
  end

  def distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def step(_e, _walls, scores, [], _processed, min_score) do
    {scores, min_score}
  end

  def step(e, walls, scores, queue, processed, min_score) do
    queue = queue |> sort

    [{cur_score, cur_point, cur_dir} | queue] = queue
    # current |> IO.inspect()

    cond do
      # c in walls or current in processed ->
      {cur_point, cur_dir} in processed ->
        # [_current | queue] = queue
        step(e, walls, scores, queue, processed, min_score)

      true ->
        scores = Map.put_new(scores, {cur_point, cur_dir}, cur_score)
        processed = MapSet.put(processed, {cur_point, cur_dir})
        min_score = if min_score == 0 && cur_point == e, do: cur_score, else: min_score

        next_dir2 = Integer.mod(cur_dir - 1, 4)
        next_dir3 = Integer.mod(cur_dir + 1, 4)

        next = cur_point |> add(dirs(cur_dir))

        candidates =
          [
            {next, cur_dir},
            {cur_point, next_dir2},
            {cur_point, next_dir3}
          ]

        queue =
          candidates
          |> reject(fn {p, _} -> p in walls end)
          |> reduce(queue, fn node, queue ->
            {node_point, node_dir} = node
            effort = if cur_dir == node_dir, do: 1, else: 1000
            node = {cur_score + effort, node_point, node_dir}
            [node | queue]
          end)

        step(e, walls, scores, queue, processed, min_score)
    end
  end

  def backwards(_e, _walls, scores, [], _processed, min_score) do
    {scores, min_score}
  end

  def backwards(e, walls, scores, queue, processed, min_score) do
    queue = queue |> sort

    [{cur_score, cur_point, cur_dir} | queue] = queue
    # current |> IO.inspect()

    cond do
      # c in walls or current in processed ->
      {cur_point, cur_dir} in processed ->
        # [_current | queue] = queue
        backwards(e, walls, scores, queue, processed, min_score)

      true ->
        scores = Map.put_new(scores, {cur_point, cur_dir}, cur_score)
        processed = MapSet.put(processed, {cur_point, cur_dir})
        min_score = if min_score == 0 && cur_point == e, do: cur_score, else: min_score

        next_dir2 = Integer.mod(cur_dir - 1, 4)
        next_dir3 = Integer.mod(cur_dir + 1, 4)

        next = cur_point |> add(dirs(Integer.mod(cur_dir + 2, 4)))

        candidates =
          [
            {next, cur_dir},
            {cur_point, next_dir2},
            {cur_point, next_dir3}
          ]

        queue =
          candidates
          |> reject(fn {p, _} -> p in walls end)
          |> reduce(queue, fn node, queue ->
            {node_point, node_dir} = node
            effort = if cur_dir == node_dir, do: 1, else: 1000
            node = {cur_score + effort, node_point, node_dir}
            [node | queue]
          end)

        backwards(e, walls, scores, queue, processed, min_score)
    end
  end

  def early(e, walls, scores, queue, processed) do
    queue = queue |> sort

    [{cur_score, cur_point, cur_dir} | queue] = queue
    # current |> IO.inspect()

    cond do
      # c in walls or current in processed ->
      {cur_point, cur_dir} in processed ->
        # [_current | queue] = queue
        early(e, walls, scores, queue, processed)

      cur_point == e ->
        cur_score

      true ->
        scores = Map.put_new(scores, {cur_point, cur_dir}, cur_score)
        processed = MapSet.put(processed, {cur_point, cur_dir})

        next_dir2 = Integer.mod(cur_dir - 1, 4)
        next_dir3 = Integer.mod(cur_dir + 1, 4)

        next = cur_point |> add(dirs(cur_dir))

        candidates =
          [
            {next, cur_dir},
            {cur_point, next_dir2},
            {cur_point, next_dir3}
          ]

        queue =
          candidates
          |> reject(fn {p, _} -> p in walls end)
          |> reduce(queue, fn node, queue ->
            {node_point, node_dir} = node
            effort = if cur_dir == node_dir, do: 1, else: 1000
            node = {cur_score + effort, node_point, node_dir}
            [node | queue]
          end)

        early(e, walls, scores, queue, processed)
    end
  end
end

Globals.start_link()

grid =
  input
  |> String.split("\n", trim: true)
  |> map(fn line -> line |> String.split("", trim: true) end)

n = count(grid) - 1

points =
  for y <- 0..n, x <- 0..n, do: {x, y}

start =
  points
  |> find(fn {x, y} -> grid |> at(y) |> at(x) == "S" end)

e =
  points
  |> find(fn {x, y} -> grid |> at(y) |> at(x) == "E" end)

walls =
  points
  |> filter(fn {x, y} -> grid |> at(y) |> at(x) == "#" end)
  |> MapSet.new()

# score, point, dir
s = {0, start, 2}

{scores, min_score} =
  Solve.step(e, walls, %{{start, 2} => 0}, [s], MapSet.new(), 0)

{scores2, _min_score2} =
  Solve.backwards(
    start,
    walls,
    %{{e, 0} => 0, {e, 1} => 0, {e, 2} => 0, {e, 3} => 0},
    [{0, e, 0}, {0, e, 1}, {0, e, 2}, {0, e, 3}],
    MapSet.new(),
    0
  )

for(x <- 0..n, y <- 0..n, d <- 0..4, do: {{x, y}, d})
# |> map(fn {p, d} -> {0, p, d} end)
|> filter(fn x -> scores[x] != nil end)
|> Task.async_stream(
  fn {p, d} ->
    # rest_score = Solve.early(e, walls, %{{p, d} => 0}, [{0, p, d}], MapSet.new())
    # {{p, d}, scores[{p, d}] + rest_score}
    {{p, d}, scores[{p, d}] + Map.get(scores2, {p, d}, 999_999)}
  end,
  timeout: :infinity
)
|> map(fn {:ok, x} -> x end)
|> group_by(fn {{p, d}, x} -> p end)
|> Map.values()
|> filter(fn group ->
  # group|> any(
  group |> any?(fn {a, b} -> b == min_score end)
end)
|> count
|> IO.inspect()

# Solve.early(e, walls, %{{start, 2} => 0}, [s], MapSet.new())
# |> dbg

# 82460 
