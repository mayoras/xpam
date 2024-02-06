defmodule Xpam.Email.Reader do
  @moduledoc """
  Module to make ETL operations over Email raw content.
  """

  @spec open_file(binary()) :: {:ok, File.io_device()} | {:error, term()}
  def open_file(path) when is_binary(path) do
    case File.open(path, [:binary, :read, :utf8]) do
      {:ok, io} -> {:ok, io}
      {:error, reason} -> {:error, "File could not be opened #{inspect(reason)}"}
    end
  end
end
