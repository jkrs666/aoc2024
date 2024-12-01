import Enum
input = File.read!("1.input")

[left_list, right_list] =
  Regex.scan(~r/(\d+)   (\d+)/, input, capture: :all_but_first)
  |> zip
  |> map(&(&1 |> Tuple.to_list))
  |> map(&(&1 |> map(fn i -> String.to_integer(i) end)))

part1 =
  [left_list, right_list]
  |> map(&(&1 |> sort))
  |> zip
  |> map(fn {a, b} -> Kernel.abs(a - b) end)
  |> sum

part2 =
  left_list
  |> map(&filter(right_list, fn x -> x == &1 end))
  |> map(&(&1 |> sum))
  |> sum

{part1, part2} |> IO.inspect
