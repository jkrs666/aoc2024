import Enum
# test = 80
# testxo = 436
# testAB = 368
# testE = 236
input = File.read!("12.input")

defmodule Areas do
  use Agent

  def start_link() do
    Agent.start_link(fn -> Map.new() end, name: __MODULE__)
  end

  def get(id) do
    Agent.get(__MODULE__, fn state ->
      Map.get(state, id, MapSet.new())
    end)
  end

  def state() do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def put(id, history) do
    Agent.update(
      __MODULE__,
      fn state ->
        Map.put(state, id, history)
      end
    )
  end
end

defmodule Visited do
  use Agent

  def start_link() do
    Agent.start_link(fn -> MapSet.new() end, name: __MODULE__)
  end

  def true?(point) do
    Agent.get(__MODULE__, fn state ->
      point in state
    end)
  end

  def state() do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def put(point) do
    Agent.update(
      __MODULE__,
      fn state ->
        MapSet.put(state, point)
      end
    )
  end
end

defmodule Solve do
  def neighbours(garden, {x, y}) do
    [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]
    |> map(fn {dx, dy} -> {x + dx, y + dy} end)
    |> filter(fn p -> garden[p] == garden[{x, y}] end)
  end

  def traverse(garden, area_id, current) do
    Visited.put(current)
    history = Areas.get(area_id)
    history = MapSet.put(history, current)
    Areas.put(area_id, history)

    neighbours =
      neighbours(garden, current)
      |> reject(fn x -> x in history end)

    case neighbours do
      [] ->
        area_id

      _ ->
        neighbours
        |> each(fn x -> traverse(garden, area_id, x) end)

        area_id
    end
  end

  def connected?({x1, y1}, {x2, y2}) do
    (abs(x1 - x2) == 1 and y1 == y2) or
      (abs(y1 - y2) == 1 and x1 == x2)
  end

  def link_count(area, {x1, y1}) do
    area
    |> filter(fn {x2, y2} ->
      connected?({x1, y1}, {x2, y2})
    end)
    |> count
  end

  def sides(area, {x, y}) do
    [
      if({x, y + 1} not in area, do: {:h, {x, "#{y}+c"}}, else: nil),
      if({x, y - 1} not in area, do: {:h, {x, "#{y}-c"}}, else: nil),
      if({x + 1, y} not in area, do: {:v, {"#{x}+c", y}}, else: nil),
      if({x - 1, y} not in area, do: {:v, {"#{x}-c", y}}, else: nil)
    ]
    |> reject(fn x -> x == nil end)
  end

  def seq_count(seq) do
    seq
    |> sort
    |> chunk_every(2, 1, :discard)
    |> map(fn [a, b] -> b - a end)
    |> count(fn diff -> diff != 1 end)
    |> Kernel.+(1)
  end

  def count_h_sides(h_sides) do
    h_sides
    |> group_by(fn {x, y} -> y end)
    |> Map.values()
    |> map(fn group ->
      group
      |> map(fn {x, y} -> x end)
      |> seq_count
    end)
    |> sum
  end

  def count_v_sides(v_sides) do
    v_sides
    |> group_by(fn {x, y} -> x end)
    |> Map.values()
    |> map(fn group ->
      group
      |> map(fn {x, y} -> y end)
      |> seq_count
    end)
    |> sum
  end

  def calculate_price(area) do
    perimeter =
      area
      |> to_list
      |> map(fn p -> link_count(area, p) end)
      |> map(fn score -> 4 - score end)
      |> sum

    perimeter * count(area)
  end

  def calculate_price2(area) do
    sides =
      area
      |> map(fn p -> sides(area, p) end)
      |> List.flatten()

    h_sides =
      sides
      |> filter(fn
        {:h, _} -> true
        _ -> false
      end)
      |> map(fn {type, p} -> p end)

    v_sides =
      sides
      |> filter(fn
        {:v, _} -> true
        _ -> false
      end)
      |> map(fn {type, p} -> p end)

    ch = count_h_sides(h_sides)
    cv = count_v_sides(v_sides)
    ca = count(area)
    ca * (ch + cv)
  end
end

Visited.start_link()
Areas.start_link()

grid =
  input
  |> String.split("\n", trim: true)
  |> map(&(&1 |> String.codepoints()))

n = count(grid) - 1

garden =
  for(y <- 0..n, x <- 0..n, do: {{x, y}, grid |> at(y) |> at(x)})
  |> Map.new()

for(y <- 0..n, x <- 0..n, do: {x, y})
|> map(fn p ->
  if Visited.true?(p) do
    {:skipped, p}
  else
    {:area, Solve.traverse(garden, p, p)}
  end
end)

# Areas.state()
# |> Map.values()
# |> map(&Solve.calculate_price(&1))
# |> sum

Areas.state()
|> Map.values()
# |> at(0)
# |> List.wrap()
|> map(&Solve.calculate_price2(&1))
|> sum
|> dbg(charlists: :as_lists)

#
# {part1, part2} |> IO.inspect()

# 841934
# 844878 too high 
# 1310340 too hi
# 1315064
