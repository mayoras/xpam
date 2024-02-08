defmodule Email.Reader do
  @moduledoc """
  Module to make EXTRACT operations (**E**TL) over Email raw content.
  """

  require Logger
  alias Email.Headers.Collector
  alias Email.Headers.Header
  alias Email.Parser

  @typedoc "An I/O device. Could be a process (pid) or an OS file descriptor."
  @type device :: pid() | {:file_descriptor, atom(), any()}

  @content_type_header "content-type"
  @content_type_pattern %{
    "text/html" => :html,
    "text/plain" => :plain,
    "multipart/mixed" => :multipart
  }

  ### OPENING/CLOSING ###
  @doc """
  Opens a file for reading.

  It opens in read mode and utf8 encoded strings.
  """
  @spec open_file(binary()) :: {:ok, device()} | {:error, term()}
  def open_file(path) when is_binary(path) do
    case File.open(path, [:binary, :read, :utf8]) do
      {:ok, io} -> {:ok, io}
      {:error, reason} -> {:error, "File could not be opened #{inspect(reason)}"}
    end
  end

  @doc """
  Closes a file.

  Delegates to File.close/1.
  """
  @spec close_file(device()) :: :ok | {:error, atom()}
  defdelegate close_file(dev), to: File, as: :close

  ### READING OPS ###
  @doc """
  Seek file descriptor to beginning of file.
  """
  @spec bof(device()) :: {:error, atom()} | {:ok, integer()}
  def bof(dev), do: :file.position(dev, {:bof, 0})

  @spec extract(device()) :: nil
  def extract(dev) do
    # extract content-type header
    with %Header{key: _key, value: value} <- Collector.get(dev, @content_type_header),
         # determine email content type
         c_type when not is_nil(c_type) <- parse_type(value) do
      # do content extraction depending on content type
      try do
        parse(dev, c_type)
      catch
        val ->
          Logger.error("Error on extract/1: #{val}")
          raise val
      end
    else
      error -> error
    end

    # return content (lazy?)
  end

  defp parse(dev, :html), do: Parser.Html.parse(dev)
  defp parse(dev, :plain), do: Parser.Plain.parse(dev)

  defp parse(_dev, :multipart) do
    throw("Extraction of multipart document not implemented.")
  end

  defp parse_type(plain) do
    plain =
      plain
      |> String.split(";")
      |> List.first()
      |> String.trim()

    case Map.get(@content_type_pattern, plain, nil) do
      nil -> {:error, :invalid_content_type}
      t -> t
    end
  end
end
