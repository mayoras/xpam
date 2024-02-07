defmodule Email.Parser do
  @doc """
  Parses a string with format.
  """
  @callback parse(String.t()) :: {:ok, term()} | {:error, atom()}
end
