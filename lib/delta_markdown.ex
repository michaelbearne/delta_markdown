defmodule DeltaMarkdown do
  @moduledoc """
  Convert Quill (Slab) [Delta](https://quilljs.com/docs/delta) document format to Markdown.

  This is useful when you want to use the rich text as context in LLM prompts.

  ## Usage
  ```
  iex> delta_markdown.to_markdown([%{"insert" => "word\\n"}])
  "word"

  ```

  ## Supported features
  ### Inline
  - ✅ Bold - bold
  - ✅ Italic - italic
  - ❌ Link - link

  ### Block
  - ❌ Blockquote - blockquote
  - ✅ Header - header
  - ✅ Indent - indent
  - ✅ List - list
  """

  @doc """
    Convert Quill Delta to Markdown.

  ## Options

  ## Examples
      iex> to_markdown([%{"insert" => "word\\n"}])
      "word"
  """
  def to_markdown(delta, _opts \\ []) do
    delta
    |> ops()
    |> Enum.flat_map(&split_lines/1)
    |> build_blocks()
    |> IO.iodata_to_binary()
  end

  defp ops(json) when is_binary(json), do: json |> JSON.decode!() |> ops()
  defp ops(%{"ops" => ops}), do: ops(ops)
  defp ops(ops) when is_list(ops), do: ops

  defp split_lines(%{"insert" => string} = op) when is_binary(string) do
    line_end? = String.ends_with?(string, "\n")
    lines = string |> String.slice(0..if(line_end?, do: -2, else: -1)//1) |> String.split("\n")

    lines
    |> Enum.with_index(1)
    |> Enum.map(fn {line, index} ->
      if index == length(lines) do
        Map.merge(op, %{"insert" => "#{line}#{if line_end?, do: "\n"}", "line_end?" => line_end?})
      else
        %{"insert" => "#{line}\n", "line_end?" => true}
      end
    end)
  end

  defp split_lines(op), do: [Map.put(op, "line_end?", false)]

  defp build_blocks(ops, markdown_acc \\ [], line_acc \\ [])
  defp build_blocks([], markdown, []), do: reverse(markdown)

  defp build_blocks([%{"line_end?" => false} = op | ops], markdown, line) do
    node = format_inline(op)
    build_blocks(ops, markdown, [node | line])
  end

  defp build_blocks([%{"insert" => text} | ops], markdown, line) when text != "\n" do
    node = [text | line]
    build_blocks(ops, [node | markdown], [])
  end

  # Blocks
  defp build_blocks([%{"attributes" => %{"header" => 1}} | ops], markdown, line) do
    node = [["\n" | line] | ["# "]]
    build_blocks(ops, [node | markdown], [])
  end

  defp build_blocks([%{"attributes" => %{"blockquote" => true}} | ops], markdown, line) do
    node = {"blockquote", [], line}

    build_blocks(ops, [node | markdown], [])
  end

  defp build_blocks([%{"attributes" => %{"list" => "ordered"} = attrs} | ops], markdown, line) do
    indent = build_indent(attrs["indent"] || 0)
    node = build_ordered_node(line, indent, markdown)
    build_blocks(ops, [node | markdown], [])
  end

  # todo could use indent to make sure that indented properly and just display a star when not
  defp build_blocks([%{"attributes" => %{"list" => "bullet"} = attrs} | ops], markdown, line) do
    indent = build_indent(attrs["indent"] || 0)
    node = [["\n" | line] | ["* ", indent]]
    build_blocks(ops, [node | markdown], [])
  end

  defp build_blocks([%{"attributes" => %{"align" => align}} | ops], markdown, line) do
    node = {"p", [{"style", "text-align: #{align};"}], line}
    build_blocks(ops, [node | markdown], [])
  end

  defp build_blocks([%{"attributes" => %{"indent" => indent}} | ops], markdown, line) do
    node = {"p", [{"style", "padding-left: #{2 * indent}em;"}], line}
    build_blocks(ops, [node | markdown], [])
  end

  defp build_blocks([%{"insert" => "\n"} | ops], markdown, []) do
    node = [""]
    build_blocks(ops, [node | markdown], [])
  end

  defp build_blocks(
         [%{"insert" => "\n"}, %{"attributes" => %{"indent" => indent}} = indent_op | ops],
         markdown,
         line
       ) do
    node = {"p", [{"style", "padding-left: #{2 * indent}em;"}], line}
    build_blocks([indent_op | ops], [node | markdown], [])
  end

  defp build_blocks([%{"insert" => "\n"} | ops], markdown, line) do
    node = line
    build_blocks(ops, [node | markdown], [])
  end

  defp format_inline(%{"attributes" => %{"bold" => true, "italic" => true}, "insert" => text}) do
    ["***", text, "***"]
  end

  defp format_inline(%{"attributes" => %{"bold" => true}, "insert" => text}) do
    ["**", text, "**"]
  end

  defp format_inline(%{"attributes" => %{"italic" => true}, "insert" => text}) do
    ["*", text, "*"]
  end

  defp format_inline(%{"insert" => text}) when is_binary(text), do: text

  defp build_indent(0), do: [""]
  defp build_indent(indent), do: for(_i <- 1..(indent * 4), do: " ")

  defp inc_number(num) do
    (String.to_integer(num) + 1) |> Integer.to_string()
  end

  defp build_ordered_node(line, indent, [[["\n" | _line], ". ", previous_num, indent] | _rest]) do
    [["\n" | line] | [". ", inc_number(previous_num), indent]]
  end

  # match when a bullet list is in between ordered list
  defp build_ordered_node(line, indent, [[["\n", _line], "* ", previous_indent] | rest])
       when length(previous_indent) > length(indent) do
    build_ordered_node(line, indent, rest)
  end

  # match when a ordered list is in between ordered list
  defp build_ordered_node(line, indent, [
         [["\n", _line], ". ", _previous_num, previous_indent] | rest
       ])
       when length(previous_indent) > length(indent) do
    build_ordered_node(line, indent, rest)
  end

  defp build_ordered_node(line, indent, _markdown) do
    [["\n" | line] | [". ", "1", indent]]
  end

  # deep reverse after processing all ops
  defp reverse(markdown) when is_list(markdown),
    do: markdown |> Enum.reverse() |> Enum.map(&reverse/1)

  defp reverse({tag, attrs, children}), do: {tag, attrs, reverse(children)}
  defp reverse(other), do: other
end
