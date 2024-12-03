import Enum
input = File.read!("3.input")

defmodule Day3 do
  def prodsum(list) do
    list
    |> map(&(&1 |> map(fn n -> String.to_integer(n) end)))
    |> map(&(&1 |> product))
    |> sum
  end
end

part1 =
  Regex.scan(~r/mul\((\d+),(\d+)\)/, input, capture: :all_but_first)
  |> Day3.prodsum()

part2 =
  Regex.scan(
    ~r/((mul\((\d+),(\d+)\))|(do(n't)?\(\)))/,
    input
  )
  |> reduce(%{muls: [], do: true}, fn x, acc ->
    case {acc.do, hd(x)} do
      {true, "mul(" <> _} -> %{acc | muls: acc.muls ++ [[x |> at(3), x |> at(4)]]}
      {_, "do()"} -> %{acc | do: true}
      {_, "don't()"} -> %{acc | do: false}
      {_, _} -> acc
    end
  end)
  |> Map.get(:muls)
  |> Day3.prodsum()

{part1, part2} |> IO.inspect()
