import Enum

defmodule Day2 do
  def safe?(list) do
    not (list |> anomaly?) && not (list |> spike?)
  end

  def safe2?(list) do
    case safe?(list) do
      true ->
        true

      _ ->
        0..length(list)
        |> map(&List.delete_at(list, &1))
        |> any?(&safe?/1)
    end
  end

  def anomaly?(list) do
    list
    |> chunk_every(3, 1, :discard)
    |> any?(fn [a, x, b] ->
      (a - x) * (x - b) <= 0
    end)
  end

  def spike?(list) do
    list
    |> chunk_every(2, 1, :discard)
    |> any?(fn [a, b] ->
      abs(a - b) not in 1..3
    end)
  end
end

input =
  File.read!("2.input")
  |> String.split("\n")
  |> filter(&(&1 != ""))
  |> map(
    &(&1
      |> String.split(" ")
      |> map(fn x -> String.to_integer(x) end))
  )

part1 = input |> count(&Day2.safe?/1)
part2 = input |> count(&Day2.safe2?/1)
{part1, part2} |> IO.inspect()
