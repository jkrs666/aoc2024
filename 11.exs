import Enum
input = File.read!("11.input")

defmodule Cache do
  use Agent

  def start_link() do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get(stone, n) do
      Agent.get(__MODULE__, fn state ->
        state[stone][n]
      end)
  end

  def state() do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def set(stone, n, result) do
    Agent.update(
      __MODULE__,
      fn state ->
        stone_map = Map.get(state, stone, %{})
        stone_map = Map.put_new(stone_map, n, result)
        Map.put(state, stone, stone_map)
      end
    )
  end
end

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
      stone == 0 -> [1]
      Integer.digits(stone) |> count |> even? -> split(stone)
      true -> [stone * 2024]
    end
  end

  def calc(stone, 1) do
    cached_result = Cache.get(stone, 1)

    case cached_result do
      nil ->
        res = mutate(stone) |> count
        Cache.set(stone, 1, res)
        res

      _ ->
        cached_result
    end
  end

  def calc(stone, n) do
    cached_result = Cache.get(stone, n)

    case cached_result do
      nil ->
        res =
          stone
          |> mutate
          |> map(fn substone -> calc(substone, n - 1) end)
          |> sum

        Cache.set(stone, n, res)
        res

      _ ->
        cached_result
    end
  end
end

Cache.start_link()

stones =
  input
  |> String.split(" ", trim: true)
  |> map(&(&1 |> String.trim() |> String.to_integer()))

part1 =
  stones
  |> Task.async_stream(&Solve.calc(&1, 25))
  |> map(fn {:ok, res} -> res end)
  |> sum

part2 =
  stones
  |> Task.async_stream(&Solve.calc(&1, 666), timeout: :infinity)
  |> map(fn {:ok, res} -> res end)
  |> sum

{part1, part2} |> IO.inspect()
