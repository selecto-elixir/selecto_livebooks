defmodule SelectoLivebooks.NotebookSeededExecutionTest do
  use ExUnit.Case, async: false

  @moduletag :seeded
  @moduletag timeout: 300_000
  @repo_root Path.expand("..", __DIR__)
  @runner Path.join(@repo_root, "scripts/verify_notebook.exs")
  @workbooks [
    "selecto_guide_examples.livemd",
    "selecto_selection_shapes_subselects_retargets.livemd",
    "selecto_filtering_system_workbook.livemd",
    "selecto_group_by_aggregates_workbook.livemd",
    "selecto_ctes_workbook.livemd",
    "selecto_other_joins_workbook.livemd",
    "selecto_domain_join_types_workbook.livemd",
    "selecto_set_operations_workbook.livemd",
    "selecto_window_functions_workbook.livemd",
    "selecto_json_operations_workbook.livemd",
    "selecto_array_unnest_lateral_workbook.livemd",
    "selecto_case_expressions_workbook.livemd",
    "selecto_values_lookup_workbook.livemd",
    "selecto_output_formats_execution_workbook.livemd"
  ]

  # These reference notebooks deliberately alter fixture data. Run only against
  # a disposable database initialized with mix setup, never create/seed it here.
  test "seeded reference cells execute without unexpected SQL failures" do
    elixir = System.find_executable("elixir") || flunk("elixir executable not found")
    repo_config = Application.fetch_env!(:selecto_livebooks, SelectoLivebooks.Repo)

    database_env =
      Enum.map(
        [
          database: "SELECTO_LIVEBOOKS_DB",
          username: "SELECTO_LIVEBOOKS_DB_USER",
          password: "SELECTO_LIVEBOOKS_DB_PASS",
          hostname: "SELECTO_LIVEBOOKS_DB_HOST",
          port: "SELECTO_LIVEBOOKS_DB_PORT"
        ],
        fn {key, name} -> {name, repo_config |> Keyword.fetch!(key) |> to_string()} end
      )

    for workbook <- @workbooks do
      {output, status} =
        System.cmd(elixir, [@runner, Path.join([@repo_root, "livebooks", workbook])],
          cd: @repo_root,
          env: [
            {"MIX_DEPS_PATH", nil},
            {"MIX_BUILD_PATH", nil},
            {"SELECTO_ECOSYSTEM_USE_LOCAL", System.get_env("SELECTO_ECOSYSTEM_USE_LOCAL", "1")}
            | database_env
          ],
          stderr_to_stdout: true
        )

      assert status == 0, "#{workbook} failed:\n#{output}"
      assert output =~ "PASS livebooks/#{workbook}"

      # Some historical cells catch and print errors. Expected negative cases
      # use explicit labels; do not mistake a caught query failure for success.
      refute output =~
               ~r/\bQUERY ERROR\b|\[FAIL\]|^(?:Error:|Execution error:|CSV export failed:|stream fold failed:)/m,
             "#{workbook} printed an unexpected failure:\n#{output}"
    end
  end
end
