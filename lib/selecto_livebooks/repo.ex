defmodule SelectoLivebooks.Repo do
  use Ecto.Repo,
    otp_app: :selecto_livebooks,
    adapter: Ecto.Adapters.Postgres
end
