defmodule DeltaMarkdown.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/michaelbearne/delta_markdown"
  @description """
  Convert Quill (Slab) Delta document format to Markdown.
  """

  def project do
    [
      app: :delta_markdown,
      version: @version,
      description: @description,
      package: package(),
      deps: deps(),
      name: "DeltaMarkdown",
      source_url: @source_url,
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"Github" => @source_url}
    ]
  end

  defp docs do
    [
      main: "DeltaMarkdown",
      extras: [
        "CHANGELOG.md": [title: "Changelog"]
      ]
    ]
  end
end
