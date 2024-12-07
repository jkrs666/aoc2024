import Enum
input = File.read!("7.input")

defmodule Solve do
  def perms2(operators, n) do
    max =
      2 ** n - 1

    for i <- 0..max do
      # split int to binary
      for <<(b::1 <- <<i::size(n)>>)>> do
        operators |> at(b)
      end
    end
  end

  def pad(list, n) do
    len = list |> length
    List.duplicate(0, n - len) ++ list
  end

  def perms3(operators, n) do
    max = 3 ** n - 1

    for i <- 0..max do
      for b3 <- Integer.digits(i, 3) |> pad(n) do
        operators |> at(b3)
      end
    end
  end

  def reduce3([a, b], [f]) do
    f.(a, b)
  end

  def reduce3([a, b | nums], [f | functions]) do
    reduce3([f.(a, b) | nums], functions)
  end

  def calibrate({true_value, operands}, functions, perms_fn) do
    functions
    |> perms_fn.(length(operands) - 1)
    |> map(&reduce3(operands, &1))
    |> find(0, &(&1 == true_value))
  end
end

calibrations =
  input
  |> String.split("\n", trim: true)
  |> map(fn row ->
    [value, operands] = row |> String.split(":")

    {
      value |> String.to_integer(),
      operands |> String.split(" ", trim: true) |> map(&String.to_integer(&1))
    }
  end)

functions = [
  fn a, b -> a + b end,
  fn a, b -> a * b end
]

part1 =
  calibrations
  |> map(&Solve.calibrate(&1, functions, fn a, b -> Solve.perms2(a, b) end))
  |> sum

part2 =
  calibrations
  |> map(
    &Solve.calibrate(
      &1,
      [
        fn a, b -> a * 10 ** (Integer.digits(b) |> length) + b end
        | functions
      ],
      fn a, b -> Solve.perms3(a, b) end
    )
  )
  |> sum
  |> dbg(charlists: :as_lists, limit: :infinity)
