defmodule Xpam.Email.Reader do
  @moduledoc """
  Module to make EXTRACT operations (**E**TL) over Email raw content.
  """

  alias Xpam.Email.Headers.Collector
  alias Xpam.Email.Headers.Header

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

  @spec extract(device()) :: nil
  def extract(dev) do
    # extract content-type header
    with %Header{key: _key, value: value} <- Collector.get(dev, @content_type_header),
         # determine email content type
         c_type when not is_nil(c_type) <- parse_type(value) do
      # do content extraction depending on content type
      do_extract(dev, c_type)
    else
      error -> error
    end

    # return content (lazy?)
  end

  defp do_extract(dev, :html) do
  end

  defp do_extract(dev, :plain) do
  end

  defp do_extract(dev, :multipart) do
  end
end
