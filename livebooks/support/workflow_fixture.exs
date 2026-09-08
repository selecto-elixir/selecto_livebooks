defmodule SelectoLivebooks.WorkflowFixture do
  @moduledoc """
  Synthetic, session-local orders for the pagination and tenant-read workbooks.
  The single-connection Postgrex pool keeps temporary tables in one session.
  Closing the connection removes every fixture table; no permanent DDL is used.
  """

  def connect! do
    options =
      SelectoLivebooksNotebookBootstrap.repo_config()
      |> Keyword.put(:pool_size, 1)

    {:ok, connection} = Postgrex.start_link(options)

    try do
      Postgrex.query!(
        connection,
        """
        CREATE TEMPORARY TABLE livebook_workflow_orders (
          id bigint PRIMARY KEY,
          tenant_id bigint NOT NULL,
          reference text NOT NULL,
          priority integer NOT NULL,
          status text NOT NULL,
          visible boolean NOT NULL
        )
        """,
        []
      )

      for row <- [
            [1, 101, "A", 3, "open", true],
            [2, 101, "B", 3, "open", true],
            [3, 101, "C", 2, "closed", true],
            [4, 101, "HIDDEN", 9, "open", false],
            [5, 202, "OTHER-TENANT", 8, "open", true],
            [6, 101, "D", 1, "open", true]
          ] do
        Postgrex.query!(
          connection,
          """
          INSERT INTO livebook_workflow_orders
            (id, tenant_id, reference, priority, status, visible)
          VALUES ($1, $2, $3, $4, $5, $6)
          """,
          row
        )
      end

      connection
    rescue
      error ->
        GenServer.stop(connection)
        reraise error, __STACKTRACE__
    end
  end

  def domain do
    %{
      name: "Workflow orders",
      source: %{
        source_table: "livebook_workflow_orders",
        primary_key: :id,
        fields: [:id, :tenant_id, :reference, :priority, :status, :visible],
        redact_fields: [],
        columns: %{
          id: %{type: :integer},
          tenant_id: %{type: :integer},
          reference: %{type: :string},
          priority: %{type: :integer},
          status: %{type: :string},
          visible: %{type: :boolean}
        },
        associations: %{}
      },
      schemas: %{},
      joins: %{},
      tenant_required: true,
      required_filters: [{"visible", true}]
    }
  end
end
