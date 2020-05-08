defmodule Ext.MixProject do
  use Mix.Project

  def project do
    [
      app: :ext,
      version: "0.1.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.0-rc"},
      {:atomic_map, "~> 0.8"},
      {:timex, "~> 3.6.1"},
      {:absinthe, "~> 1.4.0"},
      {:proper_case, "~> 1.0.2"},
      {:jason, "~> 1.0"},
      {:httpoison, "~> 1.4.0"},
      {:blankable, "~> 0.0.1"},
      {:postgrex, ">= 0.0.0-rc"},
      {:plug_cowboy, "~> 2.0"},
      {:logger_file_backend, "~> 0.0.10"},
      {:mock, "0.3.3", only: :test},
      {:ja_serializer, "~> 0.13.0"},
      {:ecto_enum, "~> 1.0"},
      {:dataloader, "~> 1.0.0"},
      {:redix, ">= 0.0.0"},
      {:porcelain, "~> 2.0"}
    ]
  end
end
