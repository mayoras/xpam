defmodule Xpam.MixProject do
  use Mix.Project

  def project do
    [
      app: :xpam,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Xpam.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:floki, "~> 0.35.0"},
      {:fast_html, "~> 2.0"},
      {:explorer, "~> 0.8.0"}
    ]
  end
end
