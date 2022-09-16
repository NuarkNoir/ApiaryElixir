defmodule LineExecutor do
  @cmdtypes [
    {~r/#.*/, :ignore},
    {~r/ECHO.*/, :echo},
    {~r/PRINT/, :print},
    {~r/ADD.*/, :add},
    {~r/CLEAR/, :clear},
    {~r/SORT.*/, :sort},
    {~r/EXIT( \d+)?/, :exit},
    {~r/RENAME.*/, :rename},
    {~r/REM.*/, :rem},
    {~r/CSPD/, :cspd}
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
    IO.puts "Unecognized command: #{line}"
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
    try do
      entities_list ++ case line |> String.split(~r/ /, trim: true) |> Enum.drop(1) do
        ["train", name, cnt, spd, dist, prefix, dest] -> [Entities.createTrain(spd, dist, "#{prefix} #{dest}", name, cnt)]
        ["boat", name, disp, year, spd, dist, prefix, dest] -> [Entities.createBoat(spd, dist, "#{prefix} #{dest}", name, disp, year)]
        ["plane", name, cap, spd, dist, len, prefix, dest] -> [Entities.createPlane(spd, dist, "#{prefix} #{dest}", name, len, cap)]
        parts -> IO.puts "Wrong args for add command: #{inspect(parts)}"; []
      end
    rescue
      e -> IO.puts "ADD error: #{Exception.message(e)}"; entities_list
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

  defp execute({:rename, line, entities_list}) do
    case line |> String.split(~r/ /, trim: true) |> Enum.drop(1) do
      [idx, new_name] -> Integer.parse(idx) |> case do
        {idx, _} -> rename_impl(entities_list, idx, new_name)
        _ -> IO.puts "Wrong index value for rename command: #{idx}"; entities_list
      end
      parts -> IO.puts "Wrong args for rename command: #{inspect(parts)}"; entities_list
    end
  end

  defp execute({:rem, line, entities_list}) do
    case line |> String.split(~r/ /, trim: true) |> Enum.drop(1) do
      ["if", attr, op, value] -> rem_impl(entities_list, attr, op, value)
      parts -> IO.puts "Wrong args for rem command: #{inspect(parts)}"; entities_list
    end
  end

  defp execute({:cspd, _, entities_list}) do
    IO.puts "Entities in list: #{entities_list |> Enum.count}"
    case entities_list do
      [] -> IO.puts("No entities in list")
      _ -> cspd_impl(entities_list, 0)
    end
    entities_list
  end

  defp print_impl(list, idx) do
    case list do
      [] -> :ok
      [head | tail] -> IO.puts "#{idx} - #{head}"; print_impl(tail, idx + 1)
    end
  end

  defp rename_impl(list, idx, new_name) do
    case list do
      _ when idx < 0 -> IO.puts "Index must be positive"; list
      [] -> IO.puts "No entity at such index"; list
      [head | tail] when idx == 0 -> [Map.put(head, "name", new_name) | tail]
      [head | tail] -> [head | rename_impl(tail, idx - 1, new_name)]
    end
  end

  defp rem_impl(list, attr, op, value) do
    cond do
      attr not in @allowedProps -> IO.puts "Unknown attribute for rem command: #{attr}"; list
      op not in ["<", ">", "=", "!="] -> IO.puts "Unknown operator for rem command: #{op}"; list
      true -> rem_impl_rec(list, attr, op, value)
    end
  end

  defp rem_impl_rec(list, attr, op, value) do
    case list do
      [] -> []
      [head | tail] ->
        attrv = if attr in ["dest", "name"], do: head[attr], else: Utils.safeIntParse(head[attr], head[attr])
        valv = if attr in ["dest", "name"], do: value, else: Utils.safeIntParse(value, value)
        if rem_impl_op(attrv, op, valv), do: rem_impl_rec(tail, attr, op, value), else: [head | rem_impl_rec(tail, attr, op, value)]
    end
  end

  defp rem_impl_op(value, op, value2) do
    case op do
      "=" -> value == value2
      "!=" -> value != value2
      ">" -> value > value2
      "<" -> value < value2
      _ -> false
    end
  end

  defp cspd_impl(list, idx) do
    case list do
      [] -> :ok
      [head | tail] ->
        IO.puts "#{idx} - #{head["name"]} will cover distance of #{head["dist"]}km
                to #{head["dest"]} with speed #{head["spd"]}km/h in #{head["dist"] / head["spd"]}h"
        cspd_impl(tail, idx + 1)
    end
  end
end
