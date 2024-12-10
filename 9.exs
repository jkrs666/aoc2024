import Enum
input = File.read!("9.input")

defmodule Solve do
  def pop_last_non_nil(disk) do
    case disk |> List.pop_at(-1) do
      {nil, disk} -> pop_last_non_nil(disk)
      {x, disk} -> {x, disk}
    end
  end

  def defrag([], result), do: result |> reverse

  def defrag([nil | disk], result) do
    {last, disk} = pop_last_non_nil(disk)
    defrag(disk, [last | result])
  end

  def defrag([x | disk], result) do
    defrag(disk, [x | result])
  end

  def expand(disk) do
    disk
    |> with_index
    |> map(fn {times, i} ->
      if Integer.mod(i, 2) == 0 do
        # file
        div(i, 2)
      else
        # space
        nil
      end
      |> List.duplicate(times)
    end)
    |> List.flatten()
  end

  def checksum(expanded_disk) do
    expanded_disk
    |> with_index
    |> map(fn {x, i} -> x * i end)
    |> sum
  end

  def part1(disk) do
    defrag(disk |> expand, [])
    |> checksum
  end

  def part2(disk) do
    disk =
      disk
      |> with_index
      |> map(fn {times, i} ->
        if Integer.mod(i, 2) == 0 do
          %{index: i, value: div(i, 2), size: times, type: :file, moved: false}
        else
          %{index: i, value: 0, size: times, type: :space}
        end
      end)

    n = count(disk)

    0..n
    |> reduce(disk, fn _, list ->
      x =
        list
        |> reverse
        |> find(fn x -> x.type == :file and x.moved == false end)

      case x do
        nil ->
          list

        _ ->
          space =
            list
            |> find(fn
              %{index: index, size: size, type: :space} ->
                {size, x.size, x.index, index, x.value}
                size >= x.size and x.index > index

              _ ->
                false
            end)

          case space do
            nil ->
              list |> List.replace_at(x.index, %{x | moved: true})

            _ ->
              res =
                list
                |> List.replace_at(space.index, %{space | size: space.size - x.size})
                |> List.replace_at(x.index, %{x | size: x.size, value: 0, type: :space})
                |> List.insert_at(space.index, %{x | moved: true})
                |> reject(fn x -> x.size == 0 end)
                |> with_index
                |> map(fn {x, i} -> %{x | index: i} end)

              res
          end
      end
    end)
  end
end

disk =
  input
  |> String.trim()
  |> String.codepoints()
  |> map(&String.to_integer(&1))

part2 =
  disk
  |> Solve.part2()
  |> map(fn
    %{size: size, value: value} ->
      value |> List.duplicate(size)
  end)
  |> List.flatten()
  |> Solve.checksum()
  |> IO.inspect()

{Solve.part1(disk), part2} |> IO.inspect()

# {6463499258318, 6493634986625}
# 
# real    0m44.465s
# user    0m57.512s
# sys     0m6.659s
