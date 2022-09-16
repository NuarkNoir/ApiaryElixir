defmodule Utils do
  def skipEmpty(list) do
    Enum.filter(list, fn x -> x != "" end)
  end

  def safeIntParse(value, replacement) do
    cond do
      is_binary(value) -> Integer.parse(value) |> case do
        {intv, _} -> intv
        _ -> replacement
      end
      true -> replacement
    end
  end

  def toInt(value) do
    cond do
      is_binary(value) -> Integer.parse(value) |> case do
        {intv, _} -> intv
        _ -> value
      end
      true -> value
    end
  end
end
