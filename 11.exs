import Enum
input = File.read!("11.input")

defmodule Solve do
  def even?(x), do: Integer.mod(x, 2) == 0

  def split(stone) do
    digits = Integer.digits(stone)

    digits
    |> chunk_every(count(digits) |> div(2))
    |> map(&Integer.undigits(&1))
  end

  def mutate(stone) do
    cond do
      stone == 0 -> 1
      Integer.digits(stone) |> count |> even? -> split(stone)
      true -> stone * 2024
    end
  end
end

stones =
  input
  |> String.split(" ", trim: true)
  |> map(&(&1 |> String.trim() |> String.to_integer()))

1..75
|> reduce(stones, fn i, stones ->
  stones =
    stones
    |> map(fn stone ->
      Solve.mutate(stone)
    end)
    |> List.flatten()

  {i,
   stones
   |> count}
  |> IO.inspect(charlits: :as_lists)

  stones
end)

# |> count

#  |> map(
#    &(&1
#      |> String.split("", trim: true)
#      |> map(fn x -> String.to_integer(x) end))
#  )

# {part1, part2} |> IO.inspect()
