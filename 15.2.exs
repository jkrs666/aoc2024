import Enum
input = File.read!("15.testL")

defmodule Solve do
  def print(width, height, dir, robot, boxes, walls) do
    case dir do
      {0, -1} -> "^"
      {0, 1} -> "v"
      {-1, 0} -> "<"
      {1, 0} -> ">"
    end
    |> IO.puts()

    " " |> IO.puts()

    for(y <- 0..height) do
      for(x <- 0..width) do
        cond do
          {x, y} == robot -> "@"
          {{x, y}, "["} in boxes -> "["
          {{x, y}, "]"} in boxes -> "]"
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

  def get_movable_boxes_h(current, dir, boxes, walls, movable) do
    next = add(current, dir)

    cond do
      next in walls ->
        []

      {next, "["} in boxes ->
        get_movable_boxes_h(next, dir, boxes, walls, [{next, "["} | movable])

      {next, "]"} in boxes ->
        get_movable_boxes_h(next, dir, boxes, walls, [{next, "]"} | movable])

      # space after boxes
      true ->
        movable
    end
  end

  def move_boxes_h(robot, dir, boxes, walls) do
    movable_boxes =
      get_movable_boxes_h(robot, dir, boxes, walls, [])

    next = add(robot, dir)

    case movable_boxes do
      [] ->
        {robot, boxes}

      _ ->
        {next,
         movable_boxes
         |> reduce(boxes, fn {box, type}, boxes ->
           new_box = {add(box, dir), type}

           boxes
           |> MapSet.delete({box, type})
           |> MapSet.put(new_box)
         end)}
    end
  end

  def move_boxes_v(robot, dir, movable_boxes, boxes, dir) do
    next = add(robot, dir)

    if :blocked in movable_boxes do
      {robot, boxes}
    else
      boxes =
        movable_boxes
        |> reduce(boxes, fn {box, type}, boxes ->
          boxes
          |> MapSet.delete({box, type})
        end)

      boxes =
        movable_boxes
        |> reduce(boxes, fn {box, type}, boxes ->
          new_box = {add(box, dir), type}

          boxes
          |> MapSet.put(new_box)
        end)

      {next, boxes}
    end
  end

  def boxtree(current, dir, boxes, walls, nodes) do
    {x, y} = current
    {dx, dy} = dir

    next = add(current, dir)

    cond do
      {next, "["} in boxes ->
        side = {x + 1, y + dy}

        boxtree(next, dir, boxes, walls, nodes |> MapSet.put({next, "["}))
        |> MapSet.union(boxtree(side, dir, boxes, walls, nodes |> MapSet.put({side, "]"})))

      {next, "]"} in boxes ->
        side = {x - 1, y + dy}

        boxtree(next, dir, boxes, walls, nodes |> MapSet.put({next, "]"}))
        |> MapSet.union(boxtree(side, dir, boxes, walls, nodes |> MapSet.put({side, "["})))

      next in walls ->
        MapSet.new([:blocked])

      true ->
        nodes
    end
  end

  def move(robot, dir, boxes, walls) do
    up = {0, -1}
    down = {0, 1}
    left = {-1, 0}
    right = {1, 0}

    next = add(robot, dir)

    #
    cond do
      next in walls ->
        {robot, boxes}

      dir in [left, right] and ({next, "]"} in boxes or {next, "["} in boxes) ->
        move_boxes_h(robot, dir, boxes, walls)

      dir in [up, down] and ({next, "]"} in boxes or {next, "["} in boxes) ->
        movable_boxes = boxtree(robot, dir, boxes, walls, MapSet.new())
        move_boxes_v(robot, dir, movable_boxes, boxes, dir)

      true ->
        {next, boxes}
    end
  end

  def part2(grid, dirs) do
    n = count(grid)
    width = 2 * n - 1
    height = n - 1

    grid =
      grid
      |> map(fn row ->
        row
        |> map(fn e ->
          case e do
            "#" -> ["#", "#"]
            "O" -> ["[", "]"]
            "." -> [".", "."]
            "@" -> ["@", "."]
          end
        end)
        |> List.flatten()
      end)

    points =
      for(y <- 0..height, x <- 0..width, do: {x, y})

    robot =
      points
      |> find(fn {x, y} -> grid |> at(y) |> at(x) == "@" end)

    walls =
      points
      |> filter(fn {x, y} -> grid |> at(y) |> at(x) == "#" end)
      |> MapSet.new()

    boxes =
      points
      |> map(fn {x, y} ->
        c = grid |> at(y) |> at(x)

        if c in ["[", "]"] do
          {{x, y}, c}
        else
          nil
        end
      end)
      |> reject(fn x -> x == nil end)
      |> MapSet.new()

    print(width, height, at(dirs, 0), robot, boxes, walls)

    {robot, boxes} =
      dirs
      |> reduce({robot, boxes}, fn dir, {robot, boxes} ->
        {robot, boxes} =
          move(robot, dir, boxes, walls)

        print(width, height, dir, robot, boxes, walls)

        {robot, boxes}
      end)

    boxes
    |> MapSet.to_list()
    |> map(fn
      {{x, y}, "["} -> 100 * y + x
      {{x, y}, "]"} -> 0
    end)
    |> sum
    |> IO.inspect()
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

Solve.part2(grid, dirs)
