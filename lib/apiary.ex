defmodule Apiary.CLI do
  @moduledoc """
  This is the main module for the Apiary CLI.
  """

  @doc """
  This is the main entry point for the Apiary CLI.
  """
  def main(path \\ "") do
    IO.puts "Loading data from '#{path}'"
    path |> get_file_lines |> LineExecutor.processLines
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
