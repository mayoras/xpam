defmodule Xpam.Email.Reader do
  @moduledoc """
  Module to make EXTRACT operations (**E**TL) over Email raw content.
  """

  alias Xpam.Email.Headers.Collector

  @typedoc "An I/O device. Could be a process (pid) or an OS file descriptor."
  @type device :: pid() | {:file_descriptor, atom(), any()}

  @valid_content_types [:html, :plain, :multipart]

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
  @spec extract(device()) :: nil
  def extract(dev) do
    # extract headers

    # determine the content type of email

    # do content extraction depending on content type

    # return content (lazy?)
  end

  defp headers(dev) do
  end

  # get email content type
  defp content_type(headers) do
  end
end
