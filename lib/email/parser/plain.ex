defmodule Email.Parser.Plain do
  @behaviour Email.Parser

  alias Email.{Reader, Parser}

  @plain_begin "\n"
  @plain_end :eof

  @impl Email.Parser
  def parse(dev) do
    # seek beginning of file
    Reader.bof(dev)

    with {:ok, _first} <- Parser.skip_until(dev, @plain_begin, [:match_whole]),
         {:ok, lines} <- Parser.read_until(dev, @plain_end),
         text <- Enum.join(lines, "\n") do
      {:ok, text}
    else
      error -> error
    end
  end
end
