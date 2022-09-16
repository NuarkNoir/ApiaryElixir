defmodule Utils do
  def skipEmpty(list) do
    Enum.filter(list, fn x -> x != "" end)
  end
end
