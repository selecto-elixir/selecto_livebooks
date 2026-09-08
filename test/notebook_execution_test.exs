defmodule SelectoLivebooks.NotebookExecutionTest do
  use ExUnit.Case, async: false

  @moduletag :postgres
  @moduletag timeout: 300_000

  @repo_root Path.expand("..", __DIR__)
  @runner Path.join(@repo_root, "scripts/verify_notebook.exs")
  @repo SelectoLivebooks.Repo
  @database_env [
    database: "SELECTO_LIVEBOOKS_DB",
    username: "SELECTO_LIVEBOOKS_DB_USER",
    password: "SELECTO_LIVEBOOKS_DB_PASS",
    hostname: "SELECTO_LIVEBOOKS_DB_HOST",
    port: "SELECTO_LIVEBOOKS_DB_PORT"
  ]
  @workbooks [
    "selecto_action_execution_workbook.livemd",
    "selecto_co_domains_workbook.livemd",
    "selecto_updato_feature_tour.livemd",
    "selecto_updato_nested_writes_workbook.livemd",
    "selecto_pagination_workbook.livemd",
    "selecto_tenant_reads_workbook.livemd"
  ]

  test "updated workbooks execute every Elixir cell" do
    elixir = System.find_executable("elixir") || flunk("elixir executable not found")
    ecosystem_mode = System.get_env("SELECTO_ECOSYSTEM_USE_LOCAL", "1")

    for workbook <- @workbooks do
      path = Path.join([@repo_root, "livebooks", workbook])

      {output, status} =
        System.cmd(elixir, [@runner, path],
          cd: @repo_root,
          env: notebook_env(ecosystem_mode),
          stderr_to_stdout: true
        )

      assert status == 0, "#{workbook} failed:\n#{output}"
      assert output =~ "PASS livebooks/#{workbook}"
    end
  end

  defp notebook_env(ecosystem_mode) do
    repo_config = Application.fetch_env!(:selecto_livebooks, @repo)

    [
      {"MIX_DEPS_PATH", nil},
      {"MIX_BUILD_PATH", nil},
      {"SELECTO_ECOSYSTEM_USE_LOCAL", ecosystem_mode}
      | database_env(repo_config)
    ]
  end

  defp database_env(repo_config) do
    Enum.map(@database_env, fn {config_key, env_name} ->
      {env_name, repo_config |> Keyword.fetch!(config_key) |> to_string()}
    end)
  end
end
