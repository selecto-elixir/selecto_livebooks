defmodule SelectoLivebooks.NotebookIntegrityTest do
  use ExUnit.Case, async: false

  @repo_root Path.expand("..", __DIR__)
  @livebook_dir Path.join(@repo_root, "livebooks")

  test "all Livebook Elixir cells parse" do
    @livebook_dir
    |> Path.join("*.livemd")
    |> Path.wildcard()
    |> Enum.flat_map(&elixir_cells/1)
    |> Enum.each(fn {path, index, source} ->
      assert {:ok, _ast} = Code.string_to_quoted(source),
             "Elixir cell #{index} in #{Path.relative_to(path, @repo_root)} does not parse"
    end)
  end

  test "every workbook is discoverable in the README" do
    readme = File.read!(Path.join(@repo_root, "README.md"))

    for path <- Path.wildcard(Path.join(@livebook_dir, "*.livemd")) do
      assert readme =~ "(livebooks/#{Path.basename(path)})"
    end
  end

  test "default test application does not start the sample Repo" do
    assert Application.get_env(:selecto_livebooks, :start_repo) == false
    assert Process.whereis(SelectoLivebooks.Repo) == nil
    refute Keyword.has_key?(Mix.Project.config()[:aliases], :test)
  end

  test "bootstrap resolves sibling SelectoUpdato checkout when present" do
    bootstrap_path = Path.join(@livebook_dir, "support/bootstrap.exs")
    Code.require_file(bootstrap_path)

    updato_root = Path.expand("../selecto_updato", @repo_root)

    if File.dir?(updato_root) do
      with_env(
        %{
          "SELECTO_ECOSYSTEM_USE_LOCAL" => "1",
          "SELECTO_LIVE_SELECTO_UPDATO_PATH" => nil
        },
        fn ->
          assert {:selecto_updato, [path: ^updato_root, override: true]} =
                   apply(SelectoLivebooksNotebookBootstrap, :updato_dep, [])
        end
      )
    end
  end

  test "Updato bootstrap is Ecto-free and includes the three portable write packages" do
    bootstrap_path = Path.join(@livebook_dir, "support/bootstrap.exs")
    Code.require_file(bootstrap_path)

    deps = apply(SelectoLivebooksNotebookBootstrap, :updato_deps, [])

    assert Enum.map(deps, &elem(&1, 0)) == [
             :selecto,
             :selecto_db_postgresql,
             :selecto_updato
           ]

    refute Enum.any?(deps, &(elem(&1, 0) in [:ecto, :ecto_sql, :selecto_livebooks]))

    notebook = File.read!(Path.join(@livebook_dir, "selecto_updato_feature_tour.livemd"))
    assert notebook =~ "SelectoLivebooksNotebookBootstrap.install_updato!()"
    assert notebook =~ "System.unique_integer([:positive, :monotonic])"
    assert notebook =~ "Keyword.put(:pool_size, 1)"
    assert notebook =~ "write: %{server_managed: true}"
    assert notebook =~ "Selecto normalizes it into canonical"
    assert notebook =~ "GenServer.stop(connection)"
    refute notebook =~ "SelectoLivebooksNotebookBootstrap.install!([updato_dep])"
    refute notebook =~ "Postgrex.stop(connection)"
  end

  test "Updato feature-tour domain previews safe adapter-owned writes without a database" do
    domain = updato_feature_tour_domain()

    selecto = %Selecto{
      domain: domain,
      adapter: SelectoDBPostgreSQL.Adapter,
      connection: :unused
    }

    context = %{tenant_id: 70_001, account_id: 80_001}

    insert =
      domain
      |> SelectoUpdato.new()
      |> SelectoUpdato.insert(%{external_id: "preview-1", name: "Preview", state: "open"})
      |> SelectoUpdato.returning([:id, :name, :state])

    assert {:ok, %{statements: [%{text: insert_sql}]}} =
             SelectoUpdato.preview(insert, selecto, context: context)

    assert insert_sql =~ ~s/INSERT INTO "updato_feature_tour_items"/
    assert insert_sql =~ ~s/EXISTS (SELECT 1 FROM "updato_feature_tour_accounts"/

    update =
      domain
      |> SelectoUpdato.new()
      |> SelectoUpdato.filter({:external_id, "preview-1"})
      |> SelectoUpdato.update(%{state: "active"})

    assert {:ok, %{statements: [%{text: update_sql}]}} =
             SelectoUpdato.preview(update, selecto, context: context)

    assert update_sql =~ ~s/"tenant_id" = $3/

    upsert =
      domain
      |> SelectoUpdato.new()
      |> SelectoUpdato.upsert(%{
        external_id: "preview-1",
        name: "Upsert preview",
        state: "active"
      })

    assert {:ok, %{statements: [%{text: upsert_sql}]}} =
             SelectoUpdato.preview(upsert, selecto, context: context)

    assert upsert_sql =~ ~s/ON CONFLICT ("tenant_id", "external_id")/
    assert upsert_sql =~ ~s/DO UPDATE SET "name" = EXCLUDED."name", "state" = EXCLUDED."state"/
    refute upsert_sql =~ ~s/SET "tenant_id"/
    refute upsert_sql =~ ~s/, "tenant_id" = EXCLUDED/
    refute upsert_sql =~ ~s/, "account_id" = EXCLUDED/
    refute upsert_sql =~ ~s/, "external_id" = EXCLUDED/

    forged =
      domain
      |> SelectoUpdato.new()
      |> SelectoUpdato.filter({:tenant_id, 70_002})
      |> SelectoUpdato.filter({:external_id, "preview-1"})
      |> SelectoUpdato.update(%{state: "forged"})

    assert {:error, %{type: :tenant_mismatch}} =
             SelectoUpdato.preview(forged, selecto, context: context)

    missing_name =
      domain
      |> SelectoUpdato.new()
      |> SelectoUpdato.insert(%{external_id: "preview-2"})

    assert {:error,
            %SelectoUpdato.Error{
              type: :validation,
              details: %{errors: [{["name"], "is required"}]}
            }} = SelectoUpdato.preview(missing_name, selecto, context: context)
  end

  test "Updato nested workbook compiles domain-governed atomic graphs" do
    domain = updato_nested_order_domain()

    operation =
      domain
      |> SelectoUpdato.new(tenant: %{tenant_id: 91_001})
      |> SelectoUpdato.insert(%{
        reference: "SO-100",
        items: [%{sku: "A", quantity: 2}, %{sku: "B", quantity: 1}]
      })
      |> SelectoUpdato.returning([:id, :reference])

    assert {:ok, %Selecto.Write.Graph{} = graph, %{tenant_id: 91_001}} =
             SelectoUpdato.PortableCommand.compile(operation)

    assert :ok = Selecto.Write.Graph.validate(graph)
    assert Enum.map(graph.nodes, & &1.id) == ["root", "items"]

    items = Enum.find(graph.nodes, &(&1.id == "items"))

    assert Enum.all?(items.rows, fn row ->
             match?(
               [
                 %Selecto.Write.Graph.Binding{
                   field: :order_id,
                   from_node: "root",
                   from_field: :id
                 }
               ],
               row.bindings
             )
           end)

    ownership_override =
      domain
      |> SelectoUpdato.new(tenant: %{tenant_id: 91_001})
      |> SelectoUpdato.insert(%{
        reference: "SO-FORGED",
        items: [%{order_id: 999, sku: "A", quantity: 2}]
      })

    assert {:error, %{type: :invalid_graph, details: %{field: :order_id}}} =
             SelectoUpdato.PortableCommand.compile(ownership_override)

    invalid_domain =
      put_in(domain, [:writes, :relationships, :items, :child_key], :missing_order_id)

    invalid_operation =
      invalid_domain
      |> SelectoUpdato.new(tenant: %{tenant_id: 91_001})
      |> SelectoUpdato.insert(%{
        reference: "SO-BAD",
        items: [%{sku: "A", quantity: 2}]
      })

    assert {:error, %{type: :invalid_operation}} =
             SelectoUpdato.PortableCommand.compile(invalid_operation)
  end

  test "Updato nested workbook authors relationship policy beside its association" do
    notebook =
      File.read!(Path.join(@livebook_dir, "selecto_updato_nested_writes_workbook.livemd"))

    assert notebook =~ "associations: %{\n      items: %{"
    assert notebook =~ "write: %{\n          writable: true"
    assert notebook =~ "owner_key: :id"
    assert notebook =~ "related_key: :order_id"
    refute notebook =~ "put_in(order_domain, [:writes, :relationships, :items, :child_key]"
  end

  test "bootstrap prefers sibling Selecto ecosystem checkouts when present" do
    bootstrap_path = Path.join(@livebook_dir, "support/bootstrap.exs")
    Code.require_file(bootstrap_path)

    selecto_root = Path.expand("../selecto", @repo_root)
    selecto_db_postgresql_root = Path.expand("../selecto_db_postgresql", @repo_root)

    with_env(
      %{
        "SELECTO_ECOSYSTEM_USE_LOCAL" => "1",
        "SELECTO_LIVE_SELECTO_PATH" => nil,
        "SELECTO_LIVE_SELECTO_DB_POSTGRESQL_PATH" => nil
      },
      fn ->
        if File.dir?(selecto_root) do
          assert {:selecto, [path: ^selecto_root, override: true]} =
                   apply(SelectoLivebooksNotebookBootstrap, :selecto_dep, [])
        end

        if File.dir?(selecto_db_postgresql_root) do
          assert {:selecto_db_postgresql, [path: ^selecto_db_postgresql_root, override: true]} =
                   apply(SelectoLivebooksNotebookBootstrap, :selecto_db_postgresql_dep, [])
        end
      end
    )
  end

  test "bootstrap standalone mode uses coordinated immutable Git revisions" do
    bootstrap_path = Path.join(@livebook_dir, "support/bootstrap.exs")
    Code.require_file(bootstrap_path)

    with_env(
      %{
        "SELECTO_ECOSYSTEM_USE_LOCAL" => "0",
        "SELECTO_LIVE_SELECTO_PATH" => nil,
        "SELECTO_LIVE_SELECTO_DB_POSTGRESQL_PATH" => nil,
        "SELECTO_LIVE_SELECTO_UPDATO_PATH" => nil,
        "SELECTO_LIVE_SELECTO_COMPONENTS_PATH" => nil
      },
      fn ->
        {pins, _} = Code.eval_file(Path.join(@livebook_dir, "support/dependency_pins.exs"))
        project_deps = apply(SelectoLivebooks.MixProject, :project, [])[:deps]

        for {app, function} <- [
              selecto: :selecto_dep,
              selecto_db_postgresql: :selecto_db_postgresql_dep,
              selecto_updato: :updato_dep,
              selecto_components: :components_dep
            ] do
          assert {^app, options} = apply(SelectoLivebooksNotebookBootstrap, function, [])
          assert options[:override]
          assert Keyword.take(options, [:git, :ref]) == Map.fetch!(pins, app)
          assert options[:ref] =~ ~r/\A[0-9a-f]{40}\z/
          assert options[:git] == "git@github.com:seeken/#{app}.git"
          {^app, project_options} = List.keyfind(project_deps, app, 0)
          assert Keyword.take(project_options, [:git, :ref]) == Map.fetch!(pins, app)
        end
      end
    )
  end

  test "bootstrap exposes repo config for Livebook Mix.install startup" do
    bootstrap_path = Path.join(@livebook_dir, "support/bootstrap.exs")
    Code.require_file(bootstrap_path)

    repo_config = apply(SelectoLivebooksNotebookBootstrap, :repo_config, [])

    assert repo_config[:database] ==
             System.get_env("SELECTO_LIVEBOOKS_DB", "selecto_livebooks_dev")

    assert repo_config[:username] == System.get_env("SELECTO_LIVEBOOKS_DB_USER", "postgres")
    assert repo_config[:hostname] == System.get_env("SELECTO_LIVEBOOKS_DB_HOST", "localhost")

    assert repo_config[:port] ==
             String.to_integer(System.get_env("SELECTO_LIVEBOOKS_DB_PORT", "5432"))

    assert repo_config[:pool_size] ==
             String.to_integer(System.get_env("SELECTO_LIVEBOOKS_DB_POOL_SIZE", "5"))
  end

  test "tenant-scope guide example generates scoped SQL" do
    domain =
      SelectoLivebooks.Domains.OrderDomain.domain()
      |> Map.put(:tenant_required, true)

    query =
      domain
      |> Selecto.configure(compile_context())
      |> Selecto.with_tenant(%{
        tenant_id: 1,
        tenant_field: "customer_id",
        required: true,
        prefix: "tenant_customer_1"
      })
      |> Selecto.apply_tenant_scope()
      |> Selecto.select(["order_number", "customer.name", "total"])
      |> Selecto.filter({"status", "delivered"})
      |> Selecto.limit(5)

    assert :ok = Selecto.validate_tenant_scope(query)
    assert Selecto.required_filters(query) == [{"customer_id", 1}]
    assert Selecto.tenant_required?(query)
    assert Selecto.Tenant.merge_execution_opts(query)[:prefix] == "tenant_customer_1"

    {sql, params} = Selecto.to_sql(query)

    assert sql =~ ~r/customer_id/i
    assert params == [1, "delivered"]
  end

  test "UDF guide example generates scalar and table-function SQL" do
    domain =
      SelectoLivebooks.Domains.ProductDomain.domain()
      |> Map.put(:functions, %{
        "lower_text" => %{
          kind: :scalar,
          sql_name: "lower",
          args: [%{name: :value, type: :string, source: :selector}],
          returns: :string,
          allowed_in: [:select, :order_by]
        },
        "series" => %{
          kind: :table,
          sql_name: "generate_series",
          args: [
            %{name: :start, type: :integer, source: :value},
            %{name: :stop, type: :integer, source: :value}
          ],
          returns: %{columns: %{value: %{type: :integer}}},
          allowed_in: [:lateral, :query_member]
        }
      })

    query =
      domain
      |> Selecto.configure(compile_context())
      |> Selecto.with_lateral(Selecto.udf_table("series", [1, 3]),
        as: "stock_bucket",
        join_type: :left
      )
      |> Selecto.select([
        Selecto.Expr.as(Selecto.udf("lower_text", ["name"]), "normalized_name"),
        "sku",
        "stock_bucket.value"
      ])
      |> Selecto.order_by([
        Selecto.Expr.as(Selecto.udf("lower_text", ["name"]), "normalized_name")
      ])
      |> Selecto.limit(5)

    {sql, params} = Selecto.to_sql(query)

    assert sql =~ ~r/lower\s*\(selecto_root\.name\)/i
    assert sql =~ ~r/generate_series\s*\(/i
    assert sql =~ ~r/join\s+lateral/i
    assert sql =~ ~r/stock_bucket\.value/i
    assert params == [1, 3]
  end

  test "retarget workbook accepts target-root post filters" do
    query =
      SelectoLivebooks.Domains.OrderDomain.domain()
      |> Selecto.configure(compile_context())
      |> Selecto.filter({"status", "delivered"})
      |> Selecto.retarget(:order_items, subquery_strategy: :exists)
      |> Selecto.post_retarget_filter({"quantity", 2})
      |> Selecto.select(["order_items.product_id", "order_items.quantity"])
      |> Selecto.limit(5)

    {sql, params} = Selecto.to_sql(query)

    assert sql =~ ~r/from\s+order_items\s+t/i
    assert sql =~ ~r/t\.quantity\s*=\s*\$2/i
    assert params == ["delivered", 2]
  end

  test "selection workbook nested subselect generates child JSON aggregate" do
    query =
      SelectoLivebooks.Domains.OrderDomain.domain()
      |> Selecto.configure(compile_context())
      |> Selecto.select(["order_number", "status", "total"])
      |> Selecto.subselect([
        %{
          target_schema: :order_items,
          fields: ["quantity", "line_total"],
          format: :json_agg,
          alias: "line_items",
          join_path: [:order_items],
          nested: [
            %{
              key: "product",
              target_schema: :products,
              fields: ["name", "sku"],
              format: :json_agg,
              join_path: [:order_items, :product]
            }
          ]
        }
      ])
      |> Selecto.limit(5)

    {sql, params} = Selecto.to_sql(query)

    assert sql =~ ~r/json_agg\(json_build_object/i
    assert sql =~ "'product'"
    assert sql =~ ~r/from\s+products\s+sub_order_items_product/i
    assert sql =~ ~r/sub_order_items_product\."id"\s*=\s*sub_order_items\."product_id"/i
    assert sql =~ ~r/as\s+"line_items"/i
    assert params == []
  end

  test "subquery join workbook exposes macro-selected subquery fields" do
    import Selecto.ExprMacros

    high_value_delivered_orders =
      SelectoLivebooks.Domains.OrderDomain.domain()
      |> Selecto.configure(compile_context())
      |> Selecto.select(select([customer_id, order_number, total]))
      |> Selecto.filter(where(status == "delivered" and total > 500))

    query =
      SelectoLivebooks.Domains.CustomerDomain.domain()
      |> Selecto.configure(compile_context())
      |> Selecto.join_subquery(:high_value_delivered, high_value_delivered_orders,
        type: :inner,
        on: [%{left: "id", right: "customer_id"}]
      )
      |> Selecto.select(
        select([
          name,
          tier,
          country,
          high_value_delivered.order_number,
          high_value_delivered.total
        ])
      )
      |> Selecto.order_by(order_by([desc(high_value_delivered.total)]))
      |> Selecto.limit(10)

    {sql, params} = Selecto.to_sql(query)

    assert sql =~ ~r/inner\s+join\s+\(/i
    assert sql =~ ~r/high_value_delivered\.order_number/i
    assert sql =~ ~r/high_value_delivered\.total/i
    assert params == ["delivered", 500]
  end

  test "strict-mode workbook boundary compiles governed SQL and rejects caller SQL" do
    strict_query = Selecto.configure(strict_mode_domain(), compile_context(), mode: :strict)

    query =
      strict_query
      |> Selecto.join(:team)
      |> Selecto.select(["status", "team.name", "status_upper"])
      |> Selecto.filter({"status", "open"})

    assert :ok = Selecto.Policy.validate_query!(query)
    {sql, params} = Selecto.to_sql(query)

    assert sql =~ "join teams"
    assert sql =~ "UPPER(selecto_root.status)"
    assert params == ["open"]

    assert_raise Selecto.PolicyViolation, ~r/query-authored :raw_sql/, fn ->
      strict_query |> Selecto.select({:raw_sql, "current_user"})
    end

    tampered = put_in(strict_query.domain[:source][:source_table], "other_orders")

    assert_raise Selecto.PolicyViolation, ~r/domain changed after strict mode sealed it/, fn ->
      tampered |> Selecto.select(["id"]) |> Selecto.to_sql()
    end
  end

  test "filtered set operands retain parameter order under outer composition" do
    domain = set_operation_domain()

    left =
      domain
      |> Selecto.configure(compile_context())
      |> Selecto.select(["title", "rental_rate"])
      |> Selecto.filter({"rating", "PG"})

    right =
      domain
      |> Selecto.configure(compile_context())
      |> Selecto.select(["title", "rental_rate"])
      |> Selecto.filter({"rating", "G"})

    query =
      Selecto.union(left, right, all: true)
      |> Selecto.order_by({"title", :asc})
      |> Selecto.limit(5)

    {sql, params} = Selecto.to_sql(query)

    assert sql =~ "selecto_root.rating = $1"
    assert sql =~ "selecto_root.rating = $2"
    assert sql =~ ~r/ORDER BY\s+1\s+asc/i
    assert sql =~ ~r/LIMIT\s+5/i
    assert params == ["PG", "G"]
  end

  test "non-connecting ecosystem verification reports prove their finite models" do
    reports = [
      Selecto.Verification.QuerySafety.verify(),
      Selecto.Verification.ContractSafety.verify(),
      Selecto.Verification.WriteRegistrySafety.verify(),
      Selecto.Verification.WriteCapabilitySafety.verify(),
      Selecto.Verification.GovernedQueryComposition.verify(),
      Selecto.Verification.WriteAuthorityNonEscalation.verify(),
      SelectoUpdato.Verification.WriteSafety.verify(),
      SelectoUpdato.Verification.ActionSafety.verify(),
      SelectoUpdato.Verification.PortableCommandSafety.verify(),
      SelectoUpdato.Verification.NestedGraphSafety.verify(),
      SelectoUpdato.Verification.TrustBoundarySafety.verify(),
      SelectoUpdato.Verification.AuthorizationLifecycleSafety.verify(),
      SelectoUpdato.Verification.TenantNonInterferenceSafety.verify(),
      SelectoUpdato.Verification.MultiAtomicitySafety.verify(),
      SelectoDBPostgreSQL.Verification.AdapterSafety.check(),
      SelectoDBPostgreSQL.Verification.PoolProtocol.check(),
      SelectoDBPostgreSQL.Verification.StreamProtocol.check(),
      SelectoDBPostgreSQL.Verification.TransactionProtocol.check(),
      SelectoComponents.Verification.ActionVisibility.verify()
    ]

    assert Enum.all?(reports, &(&1.proof_level == :bounded_exhaustive))
    assert Enum.all?(reports, & &1.proved?), inspect(reports, pretty: true)

    assert reports
           |> Enum.filter(&String.starts_with?(&1.model, "selecto."))
           |> Enum.sum_by(& &1.check_count) == 14_050

    assert reports
           |> Enum.filter(&String.starts_with?(&1.model, "selecto_updato."))
           |> Enum.sum_by(& &1.check_count) == 115_492

    assert reports
           |> Enum.filter(&String.starts_with?(&1.model, "selecto_db_postgresql."))
           |> Enum.sum_by(& &1.check_count) == 1_080

    selecto = %Selecto{adapter: SelectoDBPostgreSQL.Adapter, connection: :preview_only}
    assert {:ok, report} = Selecto.Write.AdapterConformance.check(selecto)
    assert report.operations == [:insert, :update, :upsert, :delete]
    assert length(report.batch_preview.statements) == 4

    Code.require_file(Path.join(@livebook_dir, "support/bootstrap.exs"))

    assert apply(SelectoLivebooksNotebookBootstrap, :verification_deps, [])
           |> Enum.map(&elem(&1, 0)) == [
             :selecto,
             :selecto_db_postgresql,
             :selecto_updato,
             :selecto_components
           ]
  end

  test "column defaults feed the shared Aggregate and Graph analytical shape" do
    selecto = Selecto.configure(analytics_domain(), compile_context())

    assert SelectoComponents.Views.Analytic.Defaults.group_by(selecto) == [
             {"booked_at", %{"format" => "month"}},
             {"region", %{"format" => "default"}}
           ]

    assert SelectoComponents.Views.Analytic.Defaults.aggregate(selecto) == [
             {"hours", %{"format" => "sum"}}
           ]

    view_config = %{
      view_mode: "aggregate",
      filters: [],
      views: %{
        aggregate: %{
          group_by: [{"g-1", "booked_at", %{"format" => "month"}}],
          aggregate: [{"a-1", "hours", %{"format" => "sum"}}]
        },
        graph: %{
          group_by: [],
          aggregate: [],
          visual: %{type: "bar", series: [], options: %{}}
        }
      }
    }

    graph_config = SelectoComponents.Form.ParamsState.copy_aggregate_to_graph(view_config)

    assert graph_config.view_mode == "graph"
    assert graph_config.views.graph.group_by == view_config.views.aggregate.group_by
    assert graph_config.views.graph.aggregate == view_config.views.aggregate.aggregate
    assert graph_config.views.graph.visual.type == "bar"

    params = SelectoComponents.Form.ParamsState.view_config_to_params(graph_config)

    assert params["graph_chart_type"] == "bar"
    assert params["graph_options"] == %{}
    assert params["graph_group_by"]["k0"]["field"] == "booked_at"
    assert params["graph_aggregate"]["k0"]["field"] == "hours"

    assert SelectoComponents.Form.FilterRendering.static_filter_options(%{
             options: [
               "Ready to reserve",
               {"Needs attention", "attention"},
               %{label: "Retired", value: "retired"}
             ]
           }) == [
             {"Ready to reserve", "Ready to reserve"},
             {"attention", "Needs attention"},
             {"retired", "Retired"}
           ]
  end

  test "new workbooks carry the current feature boundaries" do
    strict = File.read!(Path.join(@livebook_dir, "selecto_strict_mode_workbook.livemd"))
    verification = File.read!(Path.join(@livebook_dir, "selecto_verification_workbook.livemd"))

    analytics =
      File.read!(Path.join(@livebook_dir, "selecto_components_analytics_workbook.livemd"))

    updato = File.read!(Path.join(@livebook_dir, "selecto_updato_feature_tour.livemd"))

    nested =
      File.read!(Path.join(@livebook_dir, "selecto_updato_nested_writes_workbook.livemd"))

    assert strict =~ "mode: :strict"
    assert strict =~ "domain_sql: :forbid"
    assert verification =~ "Selecto.Verification.QuerySafety.verify()"
    assert verification =~ "SelectoComponents.Verification.ActionVisibility.verify()"
    assert analytics =~ "SelectoComponents.Views.Analytic.Defaults"
    assert analytics =~ "copy_aggregate_to_graph"
    assert analytics =~ "static_filter_options"
    assert verification =~ "SelectoUpdato.Verification.PortableCommandSafety.verify()"
    assert verification =~ "SelectoUpdato.Verification.NestedGraphSafety.verify()"
    assert verification =~ "Selecto.Verification.WriteAuthorityNonEscalation.verify()"
    assert verification =~ "Selecto.Verification.WriteCapabilitySafety.verify()"
    assert verification =~ "SelectoUpdato.Verification.AuthorizationLifecycleSafety.verify()"
    assert verification =~ "SelectoDBPostgreSQL.Verification.TransactionProtocol.check()"
    assert updato =~ "SelectoUpdato 0.4"
    assert updato =~ "required_on: [:insert]"
    assert updato =~ "returning: :all"
    assert updato =~ ".returning([:id, :name, :state])"
    assert updato =~ "Selecto.Write.AdapterConformance.check"
    assert updato =~ "cardinality_mismatch"
    assert nested =~ "Selecto.Write.Graph.validate"
    assert nested =~ "returning: :all"
    assert nested =~ ".returning([:id, :reference])"
    assert nested =~ "allowed_ops: [:insert, :update, :delete]"
    assert nested =~ "delete_missing: true"
    assert nested =~ "node_strategies"
    assert nested =~ "missing_order_id"
  end

  defp elixir_cells(path) do
    path
    |> File.read!()
    |> String.split(~r/^```elixir\s*$/m)
    |> tl()
    |> Enum.with_index(1)
    |> Enum.map(fn {rest, index} ->
      source =
        rest
        |> String.split("```", parts: 2)
        |> hd()

      {path, index, source}
    end)
  end

  defp updato_feature_tour_domain do
    %{
      name: "Updato feature-tour items",
      source: %{
        source_table: "updato_feature_tour_items",
        primary_key: :id,
        fields: [:id, :tenant_id, :account_id, :external_id, :name, :state],
        columns: %{
          id: %{type: :integer},
          tenant_id: %{type: :integer},
          account_id: %{type: :integer},
          external_id: %{type: :string},
          name: %{type: :string},
          state: %{type: :string}
        },
        associations: %{}
      },
      schemas: %{},
      writes: %{
        operations: %{
          insert: %{
            enabled: true,
            expected_cardinality: {:exactly, 1},
            returning: :all
          },
          update: %{
            enabled: true,
            expected_cardinality: {:exactly, 1},
            returning: :all
          },
          upsert: %{
            enabled: true,
            expected_cardinality: {:exactly, 1},
            conflict_targets: [[:tenant_id, :external_id]],
            returning: :all
          },
          delete: %{enabled: true, expected_cardinality: {:exactly, 1}}
        },
        fields: %{
          id: %{insertable: false, updatable: false},
          tenant_id: %{insertable: true, updatable: false, immutable: true},
          account_id: %{insertable: true, updatable: false, immutable: true},
          external_id: %{
            insertable: true,
            updatable: false,
            immutable: true,
            required_on: [:insert]
          },
          name: %{insertable: true, updatable: true, required_on: [:insert]},
          state: %{insertable: true, updatable: true}
        },
        scope: %{tenant: %{required: true, field: :tenant_id}},
        constraints: %{
          foreign_keys: %{
            account_id: %{
              source: {:context, :account_id},
              references: %{relation: "updato_feature_tour_accounts", field: :id},
              required: true
            }
          }
        }
      }
    }
  end

  defp updato_nested_order_domain do
    item_domain =
      updato_nested_domain(
        "updato_nested_items",
        [:id, :tenant_id, :order_id, :sku, :quantity],
        %{
          sku: %{insertable: true, updatable: true, required_on: [:insert]},
          quantity: %{insertable: true, updatable: true, required_on: [:insert]}
        }
      )

    updato_nested_domain(
      "updato_nested_orders",
      [:id, :tenant_id, :reference],
      %{reference: %{insertable: true, updatable: true, required_on: [:insert]}}
    )
    |> put_in([:writes, :relationships], %{
      items: %{
        writable: true,
        cardinality: :many,
        ownership: :owned,
        allowed_ops: [:insert, :update, :delete],
        domain: item_domain,
        parent_key: :id,
        child_key: :order_id,
        identity_fields: [:id],
        strategy: :sync,
        delete_missing: true,
        min_items: 1,
        max_items: 10
      }
    })
    |> put_in([:writes, :operations, :insert, :returning], :all)
    |> put_in([:writes, :operations, :update, :returning], :all)
  end

  defp updato_nested_domain(relation, fields, write_fields) do
    %{
      name: relation,
      source: %{
        source_table: relation,
        primary_key: :id,
        fields: fields,
        columns: Map.new(fields, &{&1, %{type: :string}}),
        associations: %{}
      },
      schemas: %{},
      joins: %{},
      writes: %{
        operations: %{
          insert: %{enabled: true, expected_cardinality: {:exactly, 1}},
          update: %{
            enabled: true,
            require_filter: true,
            expected_cardinality: {:exactly, 1}
          }
        },
        fields: Map.merge(%{tenant_id: %{insertable: true, immutable: true}}, write_fields),
        scope: %{tenant: %{required: true, field: :tenant_id}},
        relationships: %{}
      }
    }
  end

  defp strict_mode_domain do
    %{
      name: "Strict orders",
      source: %{
        source_table: "orders",
        primary_key: :id,
        fields: [:id, :status, :total, :team_id],
        redact_fields: [],
        columns: %{
          id: %{type: :integer},
          status: %{type: :string},
          total: %{type: :decimal},
          team_id: %{type: :integer}
        },
        associations: %{
          team: %{queryable: :team, field: :team, owner_key: :team_id, related_key: :id}
        }
      },
      schemas: %{
        team: %{
          source_table: "teams",
          primary_key: :id,
          fields: [:id, :name],
          redact_fields: [],
          columns: %{id: %{type: :integer}, name: %{type: :string}},
          associations: %{}
        }
      },
      joins: %{team: %{name: "Team", type: :left, display_field: :name}},
      custom_columns: %{
        "status_upper" => %{select: "UPPER(selecto_root.status)", type: :string}
      }
    }
  end

  defp set_operation_domain do
    %{
      name: "Films",
      source: %{
        source_table: "film",
        primary_key: :film_id,
        fields: [:film_id, :title, :rental_rate, :rating],
        redact_fields: [],
        columns: %{
          film_id: %{type: :integer},
          title: %{type: :string},
          rental_rate: %{type: :decimal},
          rating: %{type: :string}
        },
        associations: %{}
      },
      schemas: %{},
      joins: %{}
    }
  end

  defp analytics_domain do
    %{
      name: "Bookings",
      source: %{
        source_table: "bookings",
        primary_key: :id,
        fields: [:id, :booked_at, :region, :hours],
        redact_fields: [],
        columns: %{
          id: %{type: :integer},
          booked_at: %{type: :utc_datetime, default_grouping: :month},
          region: %{type: :string, default_grouping: :default},
          hours: %{type: :integer, default_aggregate: :sum}
        },
        associations: %{}
      },
      schemas: %{},
      joins: %{}
    }
  end

  defp compile_context do
    Selecto.Runtime.Context.new(SelectoDBPostgreSQL.Adapter, :compile_only)
  end

  defp with_env(changes, fun) do
    previous = Map.new(changes, fn {name, _value} -> {name, System.get_env(name)} end)

    Enum.each(changes, fn
      {name, nil} -> System.delete_env(name)
      {name, value} -> System.put_env(name, value)
    end)

    try do
      fun.()
    after
      Enum.each(previous, fn
        {name, nil} -> System.delete_env(name)
        {name, value} -> System.put_env(name, value)
      end)
    end
  end
end
