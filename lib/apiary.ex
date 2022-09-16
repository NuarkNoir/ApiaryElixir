defmodule Apiary.CLI do
  def main() do
    "D:/apiary_elixir/tests.sota" |> get_file_lines |> LineExecutor.processLines
  end

  defp get_file_lines(file) do
    case File.read(file) do
      {:ok, contents} -> contents |> String.split("\n", trim: true) |> Enum.map(&String.trim/1) |> Enum.filter(fn x -> x != "" end)
      {:error, reason} ->
        IO.puts "Error: #{reason}; Assuming empty list"
        []
    end
  end
end
