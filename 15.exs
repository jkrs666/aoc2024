import Enum
input = File.read!("15.test")

defmodule Solve do
  def print(n, dir, robot, boxes, walls) do
    case dir do
      {0, -1} -> "^"
      {0, 1} -> "v"
      {-1, 0} -> "<"
      {1, 0} -> ">"
    end
    |> IO.puts()

    for(y <- 0..n) do
      for(x <- 0..n) do
        cond do
          {x, y} == robot -> "@"
          {x, y} in boxes -> "O"
          {x, y} in walls -> "#"
          true -> "."
        end
      end
      |> join
    end
    |> join("\n")
    |> IO.puts()
  end

  def add({x1, y1}, {x2, y2}) do
    {x1 + x2, y1 + y2}
  end

  def get_movable_boxes(current, dir, boxes, walls, points) do
    next = add(current, dir)

    cond do
      next in boxes -> get_movable_boxes(next, dir, boxes, walls, [next | points])
      next in walls -> []
      # space after boxes
      true -> points
    end
  end

  def move_boxes(robot, dir, boxes, walls) do
    movable_boxes = get_movable_boxes(robot, dir, boxes, walls, [])
    next = add(robot, dir)

    case movable_boxes do
      [] ->
        {robot, boxes}

      _ ->
        {next,
         movable_boxes
         |> reduce(boxes, fn box, boxes ->
           new_box = add(box, dir)

           boxes
           |> MapSet.delete(box)
           |> MapSet.put(new_box)
         end)}
    end
  end

  def move(robot, dir, boxes, walls) do
    next = add(robot, dir)

    cond do
      next in walls ->
        {robot, boxes}

      next in boxes ->
        move_boxes(robot, dir, boxes, walls)

      true ->
        {next, boxes}
    end
  end

  def part1(grid, dirs) do
    n = count(grid) - 1

    points =
      for(y <- 0..n, x <- 0..n, do: {x, y})

    robot =
      points
      |> find(fn {x, y} -> grid |> at(y) |> at(x) == "@" end)

    walls =
      points
      |> filter(fn {x, y} -> grid |> at(y) |> at(x) == "#" end)
      |> MapSet.new()

    boxes =
      points
      |> filter(fn {x, y} -> grid |> at(y) |> at(x) == "O" end)
      |> MapSet.new()

    {robot, boxes} =
      dirs
      |> reduce({robot, boxes}, fn dir, {robot, boxes} ->
        {robot, boxes} = Solve.move(robot, dir, boxes, walls)
        # Solve.print(n, dir, robot, boxes, walls)
        {robot, boxes}
      end)

    boxes
    |> MapSet.to_list()
    |> map(fn {x, y} -> 100 * y + x end)
    |> sum
    |> dbg
  end
end

[grid, dirs] =
  input
  |> String.split("\n\n", trim: true)

grid =
  grid
  |> String.split("\n", trim: true)
  |> map(fn line -> line |> String.split("", trim: true) end)

dirs =
  dirs
  |> String.split("\n", trim: true)
  |> map(fn line -> line |> String.split("", trim: true) end)
  |> List.flatten()
  |> map(fn c ->
    case c do
      "^" -> {0, -1}
      "v" -> {0, 1}
      "<" -> {-1, 0}
      ">" -> {1, 0}
    end
  end)

Solve.part1(grid, dirs)
