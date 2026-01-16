import Config

config :selecto_examples, SelectoExamples.Repo,
  database: "selecto_examples_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :warning
