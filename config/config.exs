import Config

config :xpam,
  train: "data/train",
  test: "data/test",
  positives: "spam",
  negatives: "ham"

config :floki, :html_parser, Floki.HTMLParser.FastHtml
