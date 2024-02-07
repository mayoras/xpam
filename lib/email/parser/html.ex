defmodule Email.Parser.Html do
  @behaviour Email.Parser

  @impl Email.Parser
  def parse(raw) do
    Floki.parse_document(raw, [])
  end
end
