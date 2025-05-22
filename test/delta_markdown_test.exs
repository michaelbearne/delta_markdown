defmodule DeltaMarkdownTest do
  use ExUnit.Case, async: true

  import DeltaMarkdown

  test "empty input" do
    assert to_markdown([%{"insert" => "\n"}]) == ""
  end

  test "single word" do
    assert to_markdown([%{"insert" => "word\n"}]) ===
             """
             word
             """
  end

  test "multiple lines" do
    assert to_markdown([%{"insert" => "hello\nword\n"}]) ==
             """
             hello
             word
             """
  end

  test "heading" do
    assert to_markdown([
             %{"insert" => "Heading"},
             %{"attributes" => %{"header" => 1}, "insert" => "\n"}
           ]) ==
             "# Heading\n"
  end

  test "heading with paragraph" do
    assert to_markdown([
             %{"insert" => "Heading"},
             %{"attributes" => %{"header" => 1}, "insert" => "\n"},
             %{"insert" => "paragraph\n"}
           ]) ==
             """
             # Heading
             paragraph
             """
  end

  test "bold" do
    assert to_markdown([
             %{"attributes" => %{"bold" => true}, "insert" => "bold"},
             %{"insert" => "\n"}
           ]) == "**bold**"
  end

  test "italic" do
    assert to_markdown([
             %{"attributes" => %{"italic" => true}, "insert" => "italic"},
             %{"insert" => "\n"}
           ]) == "*italic*"
  end

  test "bold and italic" do
    assert to_markdown([
             %{"attributes" => %{"bold" => true, "italic" => true}, "insert" => "bold & italic"},
             %{"insert" => "\n"}
           ]) == "***bold & italic***"
  end

  test "consecutive inline formattings" do
    assert to_markdown([
             %{"insert" => "a"},
             %{"attributes" => %{"bold" => true}, "insert" => "b"},
             %{"insert" => "c\n"}
           ]) ===
             """
             a**b**c
             """
  end

  # todo link

  test "bullet list" do
    assert to_markdown([
             %{"insert" => "One"},
             %{"attributes" => %{"list" => "bullet"}, "insert" => "\n"},
             %{"insert" => "Two"},
             %{"attributes" => %{"list" => "bullet"}, "insert" => "\n"}
           ]) ==
             """
             * One
             * Two
             """
  end

  test "numbered list" do
    assert to_markdown([
             %{"insert" => "One"},
             %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "Two"},
             %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"}
           ]) ==
             """
             1. One
             2. Two
             """
  end

  test "numbered list with indent" do
    assert to_markdown([
             %{"insert" => "One"},
             %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "a"},
             %{"attributes" => %{"indent" => 1, "list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "b"},
             %{"attributes" => %{"indent" => 1, "list" => "ordered"}, "insert" => "\n"}
           ]) ==
             """
             1. One
                 1. a
                 2. b
             """
  end

  test "numbered list and bullet list" do
    assert to_markdown([
             %{"insert" => "One"},
             %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "x"},
             %{"attributes" => %{"list" => "bullet"}, "insert" => "\n"}
           ]) ==
             """
             1. One
             * x
             """
  end

  test "numbered list with indented bullet list" do
    assert to_markdown([
             %{"insert" => "One"},
             %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "x"},
             %{"attributes" => %{"indent" => 1, "list" => "bullet"}, "insert" => "\n"},
             %{"insert" => "Two"},
             %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"}
           ]) ==
             """
             1. One
                 * x
             2. Two
             """
  end

  test "numbered list with indented numbered list" do
    assert to_markdown([
             %{"insert" => "One"},
             %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "x"},
             %{"attributes" => %{"indent" => 1, "list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "Two"},
             %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"}
           ]) ==
             """
             1. One
                 1. x
             2. Two
             """
  end

  test "deeply nested lists" do
    assert to_markdown([
             %{"insert" => "b1"},
             %{"attributes" => %{"list" => "bullet"}, "insert" => "\n"},
             %{"insert" => "b2"},
             %{"attributes" => %{"list" => "bullet"}, "insert" => "\n"},
             %{"insert" => "b2.1"},
             %{"attributes" => %{"indent" => 1, "list" => "bullet"}, "insert" => "\n"},
             %{"insert" => "b2.1.1"},
             %{"attributes" => %{"indent" => 2, "list" => "bullet"}, "insert" => "\n"},
             %{"insert" => "n1.1"},
             %{"attributes" => %{"indent" => 1, "list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "n1"},
             %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "n2"},
             %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "n2.1.1"},
             %{"attributes" => %{"indent" => 2, "list" => "ordered"}, "insert" => "\n"}
           ]) == """
           * b1
           * b2
               * b2.1
                   * b2.1.1
               1. n1.1
           1. n1
           2. n2
                   1. n2.1.1
           """
  end

  test "complex 1" do
    assert to_markdown([
             %{"insert" => " "},
             %{"attributes" => %{"bold" => true}, "insert" => "Introduction"},
             %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "Background and Context"},
             %{"attributes" => %{"indent" => 1, "list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "Purpose of the Evaluation"},
             %{"attributes" => %{"indent" => 1, "list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "Evaluation Questions"},
             %{"attributes" => %{"indent" => 1, "list" => "ordered"}, "insert" => "\n"},
             %{"insert" => " "},
             %{"attributes" => %{"bold" => true}, "insert" => "Evaluation Subject"},
             %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "Description of UI interfaces in AI applications"},
             %{"attributes" => %{"indent" => 1, "list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "Goals of the evaluation"},
             %{"attributes" => %{"indent" => 1, "list" => "ordered"}, "insert" => "\n"},
             %{"insert" => " "},
             %{"attributes" => %{"bold" => true}, "insert" => "Evaluation Methods"},
             %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "Surveys"},
             %{"attributes" => %{"indent" => 1, "list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "Focus Groups"},
             %{"attributes" => %{"indent" => 1, "list" => "ordered"}, "insert" => "\n"},
             %{"insert" => " "},
             %{"attributes" => %{"bold" => true}, "insert" => "Data Analysis"},
             %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "Planned approach to analysing data from surveys"},
             %{"attributes" => %{"indent" => 1, "list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "Planned approach to analysing data from focus groups"},
             %{"attributes" => %{"indent" => 1, "list" => "ordered"}, "insert" => "\n"},
             %{"insert" => " "},
             %{"attributes" => %{"bold" => true}, "insert" => "Timeline"},
             %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "Key Milestones"},
             %{"attributes" => %{"indent" => 1, "list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "Deliverables"},
             %{"attributes" => %{"indent" => 1, "list" => "ordered"}, "insert" => "\n"},
             %{"insert" => " "},
             %{"attributes" => %{"bold" => true}, "insert" => "Resources"},
             %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "Budget"},
             %{"attributes" => %{"indent" => 1, "list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "Personnel"},
             %{"attributes" => %{"indent" => 1, "list" => "ordered"}, "insert" => "\n"},
             %{"insert" => " "},
             %{"attributes" => %{"bold" => true}, "insert" => "Dissemination Plan"},
             %{"attributes" => %{"list" => "ordered"}, "insert" => "\n"},
             %{"insert" => "How will the results be shared?"},
             %{"attributes" => %{"indent" => 1, "list" => "ordered"}, "insert" => "\n"}
           ]) == """
           1.  **Introduction**
               1. Background and Context
               2. Purpose of the Evaluation
               3. Evaluation Questions
           2.  **Evaluation Subject**
               1. Description of UI interfaces in AI applications
               2. Goals of the evaluation
           3.  **Evaluation Methods**
               1. Surveys
               2. Focus Groups
           4.  **Data Analysis**
               1. Planned approach to analysing data from surveys
               2. Planned approach to analysing data from focus groups
           5.  **Timeline**
               1. Key Milestones
               2. Deliverables
           6.  **Resources**
               1. Budget
               2. Personnel
           7.  **Dissemination Plan**
               1. How will the results be shared?
           """
  end
end
