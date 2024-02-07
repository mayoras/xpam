defmodule Xpam.Email.Headers.Collector do
  use Agent

  require Logger

  alias Xpam.Email.Headers.Header

  @delim ":"

  defp state, do: Agent.get(__MODULE__, & &1)

  ### INITIALIZATION ###
  def start_link(init \\ nil, opts \\ [])

  def start_link(_init, _opts) do
    Agent.start_link(fn -> struct(Header) end, name: __MODULE__)
  end

  ### API ###
  def get(dev, header \\ nil) do
    if is_nil(header) do
      # if not header specified, return the current state
      state()
    else
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

  def seek(dev, header) when not is_nil(dev) and not is_nil(header) do
    # repos the file descriptor to the beginning of file
    {:ok, _} = bof(dev)

    # start seeking
    do_seek(dev, header)
  end

  def seek(nil, _header), do: Logger.error("Device is nil, cannot read file.")

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
        reg = String.split(line, @delim)
        key = List.first(reg)

        if length(reg) == 2 and key == target do
          # found header!
          value = List.last(reg)

          # update state
          Agent.update(__MODULE__, fn state ->
            Map.update(state, :header, nil, fn _ ->
              struct(Header, key: key |> String.trim(" "), value: value |> String.trim(" "))
            end)
          end)

          # return state
          get(key)
        else
          # it isn't? keep seeking
          do_seek(dev, target)
        end
    end
  end

  defp bof(dev), do: :file.position(dev, {:bof, 0})
end
