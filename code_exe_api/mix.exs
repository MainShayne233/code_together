defmodule CodeExeApi.Mixfile do
  use Mix.Project

  def project do
    [app: :code_exe_api,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [
        :logger,
        :maru,
        :httpotion,
      ]
    ]
  end

  defp deps do
    [
      {:maru,      "~> 0.11"},
      {:httpotion, "~> 3.0.2"},
      { :exsync,   "~> 0.1", only: :dev },
    ]
  end
end
