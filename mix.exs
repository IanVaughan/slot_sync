defmodule SlotSync.Mixfile do
  use Mix.Project

  def project do
    [
      app: :slot_sync,
      version: "0.0.1",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {SlotSync.Application, []},
      extra_applications: [
        :logger,
        :confex,
        :dogstatsd,
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:confex, "~> 3.3.1"},
      {:poison, "~> 3.1.0", override: true},
      {:httpoison, "~> 0.13"},
      {:dogstatsd, "~> 0.0.3"},
      {:redix, ">= 0.0.0"},
    ]
  end

  defp aliases do
    [
      test: ["test"],
      consistency: consistency()
    ]
  end

  defp consistency do
    [
      "credo --strict"
    ]
  end
end
