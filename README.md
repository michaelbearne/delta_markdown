# DeltaMarkdown

Convert Quill (Slab) [Delta](https://quilljs.com/docs/delta) document format to Markdown in Elixir.
Render rich text entered by non technical users as Markdown so it can be used as context in a LLM prompt.

# Prior art

This is a modification of [delta_html]https://github.com/ftes/delta_html by Fredrik Teschke

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `delta_markdown` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:delta_markdown, "~> 0.1.0"}
  ]
end
```

