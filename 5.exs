import Enum
input = File.read!("5.input")

[comparison_list, input_list] =
  input
  |> String.split("\n\n", trim: true)

comparison_list =
  comparison_list
  |> String.split("\n", trim: true)
  |> map(&(&1 |> String.split("|") |> map(fn x -> String.to_integer(x) end)))

input_list =
  input_list
  |> String.split("\n", trim: true)
  |> map(&(&1 |> String.split(",") |> map(fn x -> String.to_integer(x) end)))

valid? = fn list ->
  list
  |> chunk_every(2, 1, :discard)
  |> all?(&(&1 in comparison_list))
end

median = fn list ->
  i = list |> length |> div(2)
  list |> at(i)
end

comp_sort = fn list ->
  sort(list, fn a, b -> [a, b] in comparison_list end)
end

part1 =
  input_list
  |> filter(&valid?.(&1))
  |> map(&median.(&1))
  |> sum

part2 =
  input_list
  |> filter(&(not valid?.(&1)))
  |> map(&comp_sort.(&1))
  |> map(&median.(&1))
  |> sum

{part1, part2} |> IO.inspect()
