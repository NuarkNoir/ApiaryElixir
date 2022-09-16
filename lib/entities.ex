defmodule Entities do

  @destinationPrefixes [
    "гор.", "д.", "п.г.т.", "с."
  ]

  def createBoat(spd, dist, dest, name, disp, year) do
    checkDestinationPrefix(dest)
    create("boat", %{"dist" => dist, "dest" => dest, "name" => name, "spd" => spd, "disp" => disp, "year" => year})
  end

  def createPlane(spd, dist, dest, name, len, cap) do
    checkDestinationPrefix(dest)
    create("plane", %{"spd" => spd, "dist" => dist, "dest" => dest, "name" => name, "len" => len, "cap" => cap})
  end

  @spec createTrain(any, any, any, any, any) :: %{optional(<<_::24, _::_*8>>) => any}
  def createTrain(spd, dist, dest, name, cnt) do
    checkDestinationPrefix(dest)
    create("train", %{"cnt" => cnt, "dist" => dist, "dest" => dest, "name" => name, "spd" => spd})
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
  def to_string(map) do
    case map["type"] do
      "train" -> "Train: #{map["name"]}, #{map["spd"]}km/h, #{map["dist"]}km, #{map["dest"]}, #{map["cnt"]} passengers"
      "boat" -> "Boat: #{map["name"]}, #{map["spd"]}km/h, #{map["dist"]}km, #{map["dest"]}, #{map["disp"]} displacement, #{map["year"]} year"
      "plane" -> "Plane: #{map["name"]}, #{map["spd"]}km/h, #{map["dist"]}km, #{map["dest"]}, #{map["len"]} length, #{map["cap"]} capacity"
      _ -> "Map{#{Enum.map(map, fn {k, v} -> "#{k}: #{v}" end) |> Enum.join(", ")}}"
    end
  end
end