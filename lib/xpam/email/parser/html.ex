defmodule Xpam.Email.Parser.Html do
  @behaviour Xpam.Email.Parser

  alias Xpam.Email.{Reader, Parser}

  @html_begin "<html>"
  @html_end "</html>"

  @impl Xpam.Email.Parser
  def parse(dev) do
    # seek beginning of file
    Reader.bof(dev)

    # get to the beginning of html document
    with {:ok, first} <- Parser.skip_until(dev, @html_begin),
         # read lines until end of document or EOF
         {:ok, lines} <- Parser.read_until(dev, @html_end),
         # insert beginning and join all lines
         raw <- ([first] ++ lines) |> Enum.join("\n"),
         # parse raw html content
         {:ok, tree} <- Floki.parse_document(raw),
         # get binary text from tree node
         text when text != "" <- Floki.text(tree) do
      {:ok, text}
    else
      "" -> {:error, :could_not_parse}
      error -> error
    end
  end
end
