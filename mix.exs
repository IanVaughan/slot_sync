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
        :ktsllex,
        :event_serializer,
        :kafka_ex
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
      {:httpoison, "~> 1.0"},
      {:dogstatsd, "~> 0.0.3"},
      {:redix, ">= 0.0.0"},
      {:sched_ex, "~> 1.0"},
      {:timex, "~> 3.1"},
      {:kafka_ex,
       git: "https://github.com/quiqupltd/kafka_ex.git",
       branch: "remove-raise-and-handle-reconnection"},
      {:avlizer, "~> 0.2.1"},
      {:ktsllex, github: "quiqupltd/ktsllex"},
      {:event_serializer, git: "git@gitlab.quiqup.com:backend/event_serializer.git"},
      {:distillery, "~> 1.5.2"}
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
