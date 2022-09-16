defmodule LineExecutor do
  @cmdtypes [
    {~r/#.*/, :ignore},
    {~r/ECHO.*/, :echo},
    {~r/PRINT/, :print},
    {~r/ADD.*/, :add},
    {~r/CLEAR/, :clear},
    {~r/SORT.*/, :sort},
    {~r/EXIT( \d+)?/, :exit}
    # TODO: CSPD
    # TODO: RENAME
    # TODO: REM
  ]

  @allowedProps [
    "spd", "dist", "dest", "name", "disp", "year", "len", "cap", "cnt"
  ]

  def processLines(lines) do
    case lines do
      [] -> :ok
      data -> plines(data, [])
    end
    :ok
  end

  defp plines(lines, entities_list) do
    [head | tail] = lines
    entities_list = parse(head, entities_list) |> execute
    unless tail == [] do
      plines(tail, entities_list)
    end
  end

  defp parse(line, entities_list) do
    {_, type} = Enum.find(@cmdtypes, {nil, :unknown}, fn {regex, _} ->
      String.match?(line, regex)
    end)
    {type, line, entities_list}
  end

  defp execute({:ignore, _, entities_list}) do
    entities_list
  end

  defp execute({:unknown, line, entities_list}) do
    IO.puts "Unknown command: #{line}"
    entities_list
  end

  defp execute({:echo, line, entities_list}) do
    line |> String.split(" ", trim: true) |> Enum.drop(1) |> Enum.join(" ") |> IO.puts
    entities_list
  end

  defp execute({:print, _line, entities_list}) do
    IO.puts "Entities in list: #{entities_list |> Enum.count}"
    case entities_list do
      [] -> IO.puts("No entities in list")
      _ -> print_impl(entities_list, 0)
    end
    entities_list
  end

  defp execute({:add, line, entities_list}) do
    entities_list ++ case line |> String.split(~r/ /, trim: true) |> Enum.drop(1) do
      ["train", name, cnt, spd, dist, prefix, dest] -> [Entities.createTrain(spd, dist, "#{prefix} #{dest}", name, cnt)]
      ["boat", name, disp, year, spd, dist, prefix, dest] -> [Entities.createBoat(spd, dist, "#{prefix} #{dest}", name, disp, year)]
      ["plane", name, cap, spd, dist, len, prefix, dest] -> [Entities.createPlane(spd, dist, "#{prefix} #{dest}", name, len, cap)]
      parts -> IO.puts "Wrong args for add command: #{inspect(parts)}"; []
    end
  end

  defp execute({:clear, _, _}) do
    []
  end

  defp execute({:sort, line, entities_list}) do
    attr = line |> String.split(~r/ /, trim: true) |> Enum.drop(1) |> Enum.at(0)
    cond do
      attr == nil -> IO.puts "No attribute specified for sorting"; entities_list
      attr in @allowedProps -> entities_list |> Enum.sort_by(&(&1[attr]))
      true -> IO.puts "Unknown sorting attribute: #{attr}"; entities_list
    end
  end

  defp execute({:exit, line, _}) do
    code = line |> String.split(~r/ /, trim: true) |> Enum.drop(1) |> Enum.at(0)
    IO.puts "Exiting with code #{if code == nil, do: 0, else: code}"
    case code do
      nil -> System.halt(0)
      _ -> System.halt(String.to_integer(code))
    end
  end

  defp print_impl(list, idx) do
    case list do
      [] -> :ok
      [head | tail] -> IO.puts "#{idx} - #{head}"; print_impl(tail, idx + 1)
    end
  end
end
