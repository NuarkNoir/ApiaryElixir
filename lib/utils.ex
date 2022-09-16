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
  This function converts string to integer if can, or else returns original value as is
  """
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
