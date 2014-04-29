DEFAULT_MARKDOWN_OPTIONS = {
  no_intra_emphasis: true,
  tables: true,
  fenced_code_blocks: true,
  disable_indented_code_blocks: true,
  autolink: true,
  strikethrough: true,
  superscript: true
  # footnotes: true
}

RENDERER = Redcarpet::Markdown.new(
  Redcarpet::Render::HTML,
  DEFAULT_MARKDOWN_OPTIONS)