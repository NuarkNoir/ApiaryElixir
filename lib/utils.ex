defmodule Utils do
  def skipEmpty(list) do
    Enum.filter(list, fn x -> x != "" end)
  end

  def safeIntParse(value, replacement) do
    Integer.parse(value) |> case do
      {intv, _} -> intv
      _ -> replacement
    end
  end
end
