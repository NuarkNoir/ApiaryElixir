defmodule Utils do
  @moduledoc """
  This module contains some usefule (or I thought so) utils.
  """

  @doc """
  This function removes empty strings from the list
  """
  def skipEmpty(list) do
    Enum.filter(list, fn x -> x != "" end)
  end

  @doc """
  This function converts string to integer if can, or else returns replacement value
  """
  def safeIntParse(value, replacement) do
    cond do
      is_binary(value) -> Integer.parse(value) |> case do
        {intv, _} -> intv
        _ -> replacement
      end
      true -> replacement
    end
  end

  @doc """
  This function converts string to integer if can
  """
  def toInt(value) do
    cond do
      is_integer(value) -> value
      is_binary(value) -> Integer.parse(value) |> case do
        {intv, _} -> intv
        _ -> raise "Not a number passed to Utils.toInt/1"
      end
      true -> raise "Not a number passed to Utils.toInt/1"
    end
  end
end
