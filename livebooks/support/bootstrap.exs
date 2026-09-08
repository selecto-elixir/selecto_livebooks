defmodule SelectoLivebooksNotebookBootstrap do
  @moduledoc false

  @project_root Path.expand("../..", __DIR__)
  @workspace_root Path.expand("../../..", __DIR__)
  @selecto_root Path.join(@workspace_root, "selecto")
  @selecto_db_postgresql_root Path.join(@workspace_root, "selecto_db_postgresql")
  @updato_root Path.join(@workspace_root, "selecto_updato")
  @components_root Path.join(@workspace_root, "selecto_components")

  @pins_file Path.join(__DIR__, "dependency_pins.exs")
  @external_resource @pins_file
  @pins @pins_file |> Code.eval_file() |> elem(0)

  def install!(extra_deps \\ []) do
    selecto_livebooks_dep = {:selecto_livebooks, path: @project_root, override: true}
    repo_config = repo_config()

    Mix.install(
      [
        selecto_dep(),
        selecto_db_postgresql_dep(),
        selecto_livebooks_dep,
        {:kino, "~> 0.12"}
      ] ++ List.wrap(extra_deps),
      config: [
        selecto: [default_adapter: SelectoDBPostgreSQL.Adapter],
        selecto_livebooks: [
          {SelectoLivebooks.Repo, repo_config},
          ecto_repos: [SelectoLivebooks.Repo]
        ]
      ]
    )

    assert_retarget_filter_runtime!()

    IO.puts("Using Selecto dependency: #{inspect(selecto_dep())}")
    IO.puts("Using Selecto DB PostgreSQL dependency: #{inspect(selecto_db_postgresql_dep())}")
    IO.puts("Using SelectoLivebooks dependency: #{inspect(selecto_livebooks_dep)}")
    IO.puts("Using SelectoLivebooks repo config: #{inspect(redact_password(repo_config))}")
    IO.puts("Loaded Selecto.Query from: #{loaded_module_path(Selecto.Query)}")
    :ok
  end

  def updato_deps do
    [selecto_dep(), selecto_db_postgresql_dep(), updato_dep()]
  end

  def core_deps do
    [selecto_dep(), selecto_db_postgresql_dep(), {:kino, "~> 0.12"}]
  end

  def install_core! do
    Mix.install(core_deps())

    IO.puts("Using Selecto dependency: #{inspect(selecto_dep())}")
    :ok
  end

  def install_updato! do
    Mix.install(updato_deps(),
      config: [selecto: [default_adapter: SelectoDBPostgreSQL.Adapter]]
    )

    IO.puts("Using Selecto dependency: #{inspect(selecto_dep())}")
    IO.puts("Using Selecto DB PostgreSQL dependency: #{inspect(selecto_db_postgresql_dep())}")
    IO.puts("Using SelectoUpdato dependency: #{inspect(updato_dep())}")
    IO.puts("Updato setup uses Postgrex directly; no Ecto repo configuration was installed.")
    :ok
  end

  def components_deps do
    [selecto_dep(), selecto_db_postgresql_dep(), components_dep(), {:kino, "~> 0.12"}]
  end

  def install_components! do
    Mix.install(components_deps())

    IO.puts("Using Selecto dependency: #{inspect(selecto_dep())}")
    IO.puts("Using SelectoComponents dependency: #{inspect(components_dep())}")
    :ok
  end

  def verification_deps do
    [selecto_dep(), selecto_db_postgresql_dep(), updato_dep(), components_dep()]
  end

  def install_verification! do
    Mix.install(verification_deps(),
      config: [selecto: [default_adapter: SelectoDBPostgreSQL.Adapter]]
    )

    IO.puts("Using Selecto dependency: #{inspect(selecto_dep())}")
    IO.puts("Using SelectoUpdato dependency: #{inspect(updato_dep())}")
    IO.puts("Using SelectoComponents dependency: #{inspect(components_dep())}")
    :ok
  end

  def repo_config do
    [
      database: env("SELECTO_LIVEBOOKS_DB", "selecto_livebooks_dev"),
      username: env("SELECTO_LIVEBOOKS_DB_USER", "postgres"),
      password: env("SELECTO_LIVEBOOKS_DB_PASS", "postgres"),
      hostname: env("SELECTO_LIVEBOOKS_DB_HOST", "localhost"),
      port: env_int("SELECTO_LIVEBOOKS_DB_PORT", 5432),
      pool_size: env_int("SELECTO_LIVEBOOKS_DB_POOL_SIZE", 5)
    ]
  end

  def selecto_dep do
    source_dep(
      :selecto,
      "SELECTO_LIVE_SELECTO_PATH",
      @selecto_root,
      @pins.selecto[:git],
      @pins.selecto[:ref]
    )
  end

  def selecto_db_postgresql_dep do
    source_dep(
      :selecto_db_postgresql,
      "SELECTO_LIVE_SELECTO_DB_POSTGRESQL_PATH",
      @selecto_db_postgresql_root,
      @pins.selecto_db_postgresql[:git],
      @pins.selecto_db_postgresql[:ref]
    )
  end

  def updato_dep do
    source_dep(
      :selecto_updato,
      "SELECTO_LIVE_SELECTO_UPDATO_PATH",
      @updato_root,
      @pins.selecto_updato[:git],
      @pins.selecto_updato[:ref]
    )
  end

  def components_dep do
    source_dep(
      :selecto_components,
      "SELECTO_LIVE_SELECTO_COMPONENTS_PATH",
      @components_root,
      @pins.selecto_components[:git],
      @pins.selecto_components[:ref]
    )
  end

  defp source_dep(app, path_env, sibling_root, git, ref) do
    source =
      case System.get_env(path_env) do
        path when is_binary(path) and path != "" ->
          [path: Path.expand(path)]

        _ ->
          if use_local_ecosystem?() and File.dir?(sibling_root) do
            [path: sibling_root]
          else
            [git: git, ref: ref]
          end
      end

    {app, source ++ [override: true]}
  end

  defp use_local_ecosystem? do
    case System.get_env("SELECTO_ECOSYSTEM_USE_LOCAL") do
      value when value in ["1", "true", "TRUE", "yes", "YES", "on", "ON"] -> true
      value when value in ["0", "false", "FALSE", "no", "NO", "off", "OFF"] -> false
      _ -> true
    end
  end

  defp env(name, default), do: System.get_env(name, default)

  defp env_int(name, default) do
    case System.get_env(name) do
      nil -> default
      value -> String.to_integer(value)
    end
  end

  defp redact_password(config) do
    Keyword.update(config, :password, nil, fn
      nil -> nil
      "" -> ""
      _password -> "[REDACTED]"
    end)
  end

  defp assert_retarget_filter_runtime! do
    runtime = apply(Selecto.Runtime.Context, :new, [SelectoDBPostgreSQL.Adapter, :compile_only])

    selecto = apply(Selecto, :configure, [retarget_smoke_domain(), runtime, [validate: false]])

    selecto = apply(Selecto, :retarget, [selecto, :order_items])
    apply(Selecto, :post_retarget_filter, [selecto, {"quantity", 2}])

    :ok
  rescue
    error in ArgumentError ->
      reraise """
              Selecto retarget filter smoke check failed during Livebook setup.

              The loaded Selecto runtime does not accept target-root post-retarget filters like {"quantity", 2}.
              Disconnect/reconnect the Livebook runtime, then rerun the setup cell so Mix.install reloads the local Selecto checkout.

              Loaded Selecto.Query from: #{loaded_module_path(Selecto.Query)}
              Original error: #{Exception.message(error)}
              """,
              __STACKTRACE__
  end

  defp retarget_smoke_domain do
    %{
      name: "Retarget Smoke",
      source: %{
        source_table: "orders",
        primary_key: :id,
        fields: [:id, :status],
        redact_fields: [],
        columns: %{
          id: %{type: :integer},
          status: %{type: :string}
        },
        associations: %{
          order_items: %{
            queryable: :order_items,
            field: :order_items,
            owner_key: :id,
            related_key: :order_id
          }
        }
      },
      schemas: %{
        order_items: %{
          source_table: "order_items",
          primary_key: :id,
          fields: [:id, :order_id, :quantity],
          redact_fields: [],
          columns: %{
            id: %{type: :integer},
            order_id: %{type: :integer},
            quantity: %{type: :integer}
          },
          associations: %{}
        }
      },
      joins: %{
        order_items: %{type: :left, name: "order_items"}
      }
    }
  end

  defp loaded_module_path(module) do
    case :code.which(module) do
      path when is_list(path) -> List.to_string(path)
      path -> inspect(path)
    end
  end
end
