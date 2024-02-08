defmodule Xpam.Email.Headers.Header do
  defstruct key: nil, value: nil

  def normalize(header) do
    header
    |> String.trim(" ")
    |> String.downcase()
  end
end
