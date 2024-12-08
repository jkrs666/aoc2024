import Enum
input = File.read!("7.input")

defmodule Solve do
  def pad(list, n) do
    len = list |> length
    List.duplicate(0, n - len) ++ list
  end

  def perms(functions, n) do
    base = functions |> length
    max = base ** n - 1

    0..max
    |> Stream.map(fn i ->
      Integer.digits(i, base)
      |> pad(n)
      |> map(&at(functions, &1))
    end)
  end

  def reduce3([a, b], [f]), do: f.(a, b)

  def reduce3([a, b | nums], [f | functions]) do
    reduce3([f.(a, b) | nums], functions)
  end

  def calibrate({true_value, operands}, functions) do
    functions
    |> perms(length(operands) - 1)
    |> find_value(0, &if(true_value == reduce3(operands, &1), do: true_value))
  end
end

calibrations =
  input
  |> String.split("\n", trim: true)
  |> map(fn row ->
    [value, operands] = row |> String.split(":")

    {
      value |> String.to_integer(),
      operands
      |> String.split(" ", trim: true)
      |> map(&String.to_integer/1)
    }
  end)

functions = [
  fn a, b -> a + b end,
  fn a, b -> a * b end
]

functions2 = [
  fn a, b -> a * 10 ** count(Integer.digits(b)) + b end
  | functions
]

part1 =
  calibrations
  |> Task.async_stream(&Solve.calibrate(&1, functions))
  |> reduce(0, fn {:ok, num}, acc -> acc + num end)

part2 =
  calibrations
  |> Task.async_stream(&Solve.calibrate(&1, functions2))
  |> reduce(0, fn {:ok, num}, acc -> acc + num end)

{part1, part2} |> IO.inspect()
