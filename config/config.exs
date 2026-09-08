import Config

config :selecto, default_adapter: SelectoDBPostgreSQL.Adapter

config :selecto_livebooks,
  ecto_repos: [SelectoLivebooks.Repo]

config :selecto_livebooks, SelectoLivebooks.Repo,
  database: System.get_env("SELECTO_LIVEBOOKS_DB", "selecto_livebooks_dev"),
  username: System.get_env("SELECTO_LIVEBOOKS_DB_USER", "postgres"),
  password: System.get_env("SELECTO_LIVEBOOKS_DB_PASS", "postgres"),
  hostname: System.get_env("SELECTO_LIVEBOOKS_DB_HOST", "localhost"),
  port: String.to_integer(System.get_env("SELECTO_LIVEBOOKS_DB_PORT", "5432")),
  pool_size: 10

import_config "#{config_env()}.exs"
