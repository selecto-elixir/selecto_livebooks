import Config

config :selecto_livebooks, start_repo: false

config :selecto_livebooks, SelectoLivebooks.Repo,
  database:
    System.get_env("SELECTO_LIVEBOOKS_DB") ||
      "selecto_livebooks_test#{System.get_env("MIX_TEST_PARTITION")}",
  username: System.get_env("SELECTO_LIVEBOOKS_DB_USER", "postgres"),
  password: System.get_env("SELECTO_LIVEBOOKS_DB_PASS", "postgres"),
  hostname: System.get_env("SELECTO_LIVEBOOKS_DB_HOST", "localhost"),
  port: String.to_integer(System.get_env("SELECTO_LIVEBOOKS_DB_PORT", "5432")),
  pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :warning
