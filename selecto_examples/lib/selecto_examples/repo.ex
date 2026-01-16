defmodule SelectoExamples.Repo do
  use Ecto.Repo,
    otp_app: :selecto_examples,
    adapter: Ecto.Adapters.Postgres
end
