import Enum
input = File.read!("13.input")

defmodule Solve do
  def add_points({x1, y1}, {x2, y2}) do
    {x1 + x2, y1 + y2}
  end

  def mul_point({x, y}, n) do
    {x * n, y * n}
  end

  def less?({x1, y1}, {x2, y2}) do
    x1 < x2 or y1 < y2
  end

  def combos(prize, a, b, counta, countb) do
    cost = counta * 3 + countb
    next = mul_point(a, counta) |> add_points(mul_point(b, countb))
    # {next, counta, countb, cost} |> IO.inspect()

    cond do
      # less?(next, prize) or counta < 0 or countb < 0 -> false
      # next == prize -> {counta, countb, cost}
      next == prize -> cost
      true -> :infinity
    end
  end

  def quick_mafs(a, b, prize) do
    {a1, a2} = a
    {b1, b2} = b
    {p1, p2} = prize

    countb = (a1 * p2 - a2 * p1) / (a1 * b2 - b1 * a2)
    counta = (p1 - b1 * countb) / a1

    if countb - floor(countb) == 0 and counta - floor(counta) == 0 do
      {:ok, {counta, countb}}
    else
      {:fail, {counta, countb}}
    end
  end
end

a = {94, 34}
b = {22, 67}
prize = {8400, 5400}

a = {94, 34}
b = {22, 67}
prize = {10_000_000_008_400, 10_000_000_005_400}

Solve.quick_mafs(a, b, prize)
|> dbg

claw_machines =
  input
  |> String.split("\n\n")
  |> map(
    &(Regex.scan(~r/(\d+)+/, &1, capture: :all_but_first)
      |> List.flatten()
      |> map(fn i -> String.to_integer(i) end))
  )
  |> map(fn [ax, ay, bx, by, prizex, prizey] -> [{ax, ay}, {bx, by}, {prizex, prizey}] end)

part1 =
  claw_machines
  |> map(fn [a, b, prize] ->
    for(i <- 100..0, j <- 100..0, do: Solve.combos(prize, a, b, i, j))
    |> reject(&(&1 == :infinity))
  end)
  |> List.flatten()
  |> sum

part2 =
  claw_machines
  |> map(fn [a, b, prize] ->
    Solve.quick_mafs(a, b, Solve.add_points(prize, {10_000_000_000_000, 10_000_000_000_000}))
  end)
  |> map(fn
    {:ok, {a, b}} -> floor(a) * 3 + floor(b)
    {:fail, _} -> 0
  end)
  |> sum
  |> dbg
