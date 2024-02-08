defmodule Email.Headers.Collector do
  use Agent

  require Logger

  alias Email.Headers.Header
  alias Email.Reader

  @type t :: %Header{}

  @delim ":"

  defp state, do: Agent.get(__MODULE__, & &1)

  ### INITIALIZATION ###
  def start_link(init \\ nil, opts \\ [])

  def start_link(_init, _opts) do
    Agent.start_link(fn -> struct(Header) end, name: __MODULE__)
  end

  ### API ###
  @spec get(Reader.device(), String.t() | nil) :: t() | :ok | {:error, atom()}
  def get(dev, header \\ nil) do
    if is_nil(header) do
      # if not header specified, return the current state
      state()
    else
      # normalize header
      header = header |> Header.normalize()

      # get the current state
      curr_head = state()

      if header == curr_head.key do
        # return current state if state matches client's request
        curr_head
      else
        # else just seek for the header requested
        seek(dev, header)
      end
    end
  end

  defp seek(dev, header) when not is_nil(dev) and not is_nil(header) do
    # repos the file descriptor to the beginning of file
    {:ok, _} = Reader.bof(dev)

    # start seeking
    do_seek(dev, header)
  end

  defp seek(nil, _header), do: Logger.error("Device is nil, cannot read file.")

  defp do_seek(dev, target) when not is_nil(target) do
    # read line
    case IO.read(dev, :line) do
      :eof ->
        Logger.warning("Reached EOF on reading file.")
        {:error, :header_not_found}

      "\n" ->
        Logger.info("End of headers' section on reading file.")
        {:error, :header_not_found}

      {:error, reason} ->
        Logger.error("ERROR do_seek - could not read line on file: #{inspect(reason)}")
        {:error, reason}

      line when is_binary(line) ->
        reg = String.split(line, @delim, parts: 2)
        key = List.first(reg) |> Header.normalize()

        if length(reg) == 2 and key == target do
          # found header!
          value = List.last(reg)

          # update state
          Agent.update(__MODULE__, fn _state ->
            struct(Header,
              key: key,
              value: value |> String.trim(" ")
            )
          end)

          # return state
          get(dev, target)
        else
          # it isn't? keep seeking
          do_seek(dev, target)
        end
    end
  end
end
