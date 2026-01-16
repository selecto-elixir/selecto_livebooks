import Config

config :selecto_examples,
  ecto_repos: [SelectoExamples.Repo]

config :selecto_examples, SelectoExamples.Repo,
  database: "selecto_examples_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

import_config "#{config_env()}.exs"
