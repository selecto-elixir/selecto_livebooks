defmodule SelectoLivebooks.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      if Application.get_env(:selecto_livebooks, :start_repo, true),
        do: [SelectoLivebooks.Repo],
        else: []

    opts = [strategy: :one_for_one, name: SelectoLivebooks.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
