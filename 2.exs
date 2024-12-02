import Enum

defmodule Day2 do
  def safe?(list) do
    list |> anomaly? |> empty? &&
      list |> spike? |> empty?
  end

  def safe2?(list) do
    unsafe_indexes = ((list |> anomaly?) ++ (list |> spike?)) |> List.flatten()

    case unsafe_indexes do
      [] -> true
      _ -> unsafe_indexes |> map(&List.delete_at(list, &1)) |> any?(&safe?/1)
    end
  end

  def anomaly?(list) do
    list
    |> chunk_every(3, 1, :discard)
    |> with_index
    |> map(fn {[a, x, b], index} ->
      %{
        pos: [index, index + 1, index + 2],
        elem: [a, x, b],
        anomaly: (a - x) * (x - b) <= 0
      }
    end)
    |> filter(& &1.anomaly)
    |> map(fn %{pos: x} -> x end)
  end

  def spike?(list) do
    list
    |> chunk_every(2, 1, :discard)
    |> with_index
    |> map(fn {[a, b], index} ->
      %{
        pos: [index, index + 1],
        elem: [a, b],
        spike: abs(a - b) not in 1..3
      }
    end)
    |> filter(& &1.spike)
    |> map(fn %{pos: x} -> x end)
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
