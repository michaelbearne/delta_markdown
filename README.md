# DeltaMarkdown

Convert Quill (Slab) [Delta](https://quilljs.com/docs/delta) document format to Markdown in Elixir.
Render rich text entered by non technical users as Markdown so it can be used as context in a LLM prompt.

# Prior art

This is a modification of [delta_html](https://github.com/ftes/delta_html) by Fredrik Teschke

## Installation

```elixir
def deps do
  [
    {:delta_markdown, "~> 0.1.0"}
  ]
end
```

