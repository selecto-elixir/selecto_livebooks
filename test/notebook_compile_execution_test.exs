defmodule SelectoLivebooks.NotebookCompileExecutionTest do
  use ExUnit.Case, async: false

  @moduletag timeout: 300_000
  @repo_root Path.expand("..", __DIR__)
  @runner Path.join(@repo_root, "scripts/verify_notebook.exs")
  @workbooks [
    "selecto_action_authorization_lifecycle_workbook.livemd",
    "selecto_action_form_workbook.livemd",
    "selecto_action_observability_workbook.livemd",
    "selecto_actions_workbook.livemd",
    "selecto_choice_membership_workbook.livemd",
    "selecto_domain_contracts_workbook.livemd",
    "selecto_domain_evolution_workbook.livemd",
    "selecto_first_query_workbook.livemd",
    "selecto_query_library_workbook.livemd",
    "selecto_strict_mode_workbook.livemd",
    "selecto_components_analytics_workbook.livemd",
    "selecto_domain_extensions_workbook.livemd",
    "selecto_verification_workbook.livemd"
  ]

  for workbook <- @workbooks do
    test "database-free cells execute: #{workbook}" do
      workbook = unquote(workbook)
      elixir = System.find_executable("elixir") || flunk("elixir executable not found")

      {output, status} =
        System.cmd(elixir, [@runner, Path.join([@repo_root, "livebooks", workbook])],
          cd: @repo_root,
          env: [
            {"MIX_DEPS_PATH", nil},
            {"MIX_BUILD_PATH", nil},
            {"SELECTO_ECOSYSTEM_USE_LOCAL", System.get_env("SELECTO_ECOSYSTEM_USE_LOCAL", "1")},
            {"SELECTO_LIVEBOOKS_DB_PORT", "1"}
          ],
          stderr_to_stdout: true
        )

      assert status == 0, "#{workbook} failed:\n#{output}"
      assert output =~ "PASS livebooks/#{workbook}"
      refute output =~ "failed to connect"
    end
  end
end
