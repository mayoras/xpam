defmodule Email.Parser do
  @doc """
  Parses a string with format.
  """
  @callback parse(Email.Reader.device()) :: {:ok, term()} | {:error, atom()}

  @doc """
  Skips content from IO device until a `stopper` presents and returns the stopper.
  """
  @spec skip_until(Email.Reader.device(), String.t()) :: {:ok, String.t()} | {:error, atom()}
  def skip_until(dev, stopper, opts \\ []) do
    line = IO.read(dev, :line)

    cond do
      :eof ->
        {:error, :eof_reached}

      :match_whole in opts and line == stopper ->
        # return in case line match whole stopper line
        {:ok, line}

      :match_whole not in opts and String.contains?(line, stopper) ->
        # return when simply line contains the stopper string
        {:ok, line}

      true ->
        # else, keep reading
        skip_until(dev, stopper)
    end
  end

  @doc """
  Reads from IO device until `stopper` is present. Returns all lines read including the `stopper` line. Returns full binary in case of EOF stopper.
  """
  @spec read_until(Email.Reader.device(), String.t() | :eof, list(atom())) ::
          {:ok, list(String.t())} | {:ok, binary()}
  def read_until(dev, stopper, lines \\ [])

  def read_until(dev, :eof, _lines) do
    IO.read(dev, :eof)
  end

  def read_until(dev, stopper, lines) when is_binary(stopper) do
    line = IO.read(dev, :line)

    cond do
      :eof ->
        {:ok, lines}

      String.contains?(line, stopper) ->
        # return when line is or contains the stopper string
        {:ok, lines ++ [line]}

      true ->
        # else, keep reading
        read_until(dev, stopper, lines ++ [line])
    end
  end
end
