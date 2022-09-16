defmodule Entities do
  @moduledoc """
  This module contains utils for the entities in the Apiary.
  """

  @destinationPrefixes [
    "гор.", "д.", "п.г.т.", "с."
  ]

  @doc """
  This function creates boat entity map
  """
  def createBoat(spd, dist, dest, name, disp, year) do
    checkDestinationPrefix(dest)
    create("boat", %{"dist" => Utils.toInt(dist), "dest" => dest, "name" => name, "spd" => Utils.toInt(spd), "disp" => Utils.toInt(disp), "year" => Utils.toInt(year)})
  end

  @doc """
  This function creates plane entity map
  """
  def createPlane(spd, dist, dest, name, len, cap) do
    checkDestinationPrefix(dest)
    create("plane", %{"spd" => Utils.toInt(spd), "dist" => Utils.toInt(dist), "dest" => dest, "name" => name, "len" => Utils.toInt(len), "cap" => Utils.toInt(cap)})
  end

  @doc """
  This function creates train entity map
  """
  def createTrain(spd, dist, dest, name, cnt) do
    checkDestinationPrefix(dest)
    create("train", %{"cnt" => Utils.toInt(cnt), "dist" => Utils.toInt(dist), "dest" => dest, "name" => name, "spd" => Utils.toInt(spd)})
  end

  defp create(type, params) do
    Map.merge(%{ "type" => type}, params)
  end

  defp checkDestinationPrefix(destination) do
    case Enum.find(@destinationPrefixes, nil, fn prefix -> String.starts_with?(destination, prefix) end) do
      nil -> raise "Wrong destination prefix in: #{destination}"
      _ -> true
    end
  end
end

defimpl String.Chars, for: Map do
  @doc """
  This function converts any map to string, and nicely does it for our entities
  """
  def to_string(map) do
    case map["type"] do
      "train" -> "Train: #{map["name"]}, #{map["spd"]}km/h, #{map["dist"]}km, #{map["dest"]}, #{map["cnt"]} passengers"
      "boat" -> "Boat: #{map["name"]}, #{map["spd"]}km/h, #{map["dist"]}km, #{map["dest"]}, #{map["disp"]} displacement, #{map["year"]} year"
      "plane" -> "Plane: #{map["name"]}, #{map["spd"]}km/h, #{map["dist"]}km, #{map["dest"]}, #{map["len"]} length, #{map["cap"]} capacity"
      _ -> "Map{#{Enum.map(map, fn {k, v} -> "#{k}: #{v}" end) |> Enum.join(", ")}}"
    end
  end
end
