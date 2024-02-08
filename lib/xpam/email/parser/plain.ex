defmodule Xpam.Email.Parser.Plain do
  @behaviour Xpam.Email.Parser

  alias Xpam.Email.{Reader, Parser}

  @plain_begin "\n"
  @plain_end :eof

  @impl Xpam.Email.Parser
  def parse(dev) do
    # seek beginning of file
    Reader.bof(dev)

    with {:ok, _first} <- Parser.skip_until(dev, @plain_begin, [:match_whole]),
         {:ok, text} when is_binary(text) <- Parser.read_until(dev, @plain_end) do
      {:ok, text}
    else
      error -> error
    end
  end
end
