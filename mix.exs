defmodule SlackRtm.Mixfile do
  use Mix.Project

  def project do
    [app: :slack_rtm,
     version: "0.0.1",
     elixir: "~> 1.3",
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :httpoison]]
  end

  defp description do
    """
    Slack RTM API client.
    """
  end

  defp deps do
    [
      {:socket, "~> 0.3.5"},
      {:httpoison, "~> 0.9.2"},
      {:poison, "~> 3.0"},
      {:ex_doc, "~> 0.14.3", only: :docs},
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      contributors: ["mtgto"],
      licenses: ["The MIT License"],
      links: %{
        "GitHub" => "https://github.com/mtgto/Elixir-SlackRTM"
      }
    ]
  end
end
