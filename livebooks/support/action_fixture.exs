defmodule SelectoLivebooks.ActionFixture do
  @moduledoc "Synthetic approval domain shared by action planning and live execution notebooks."

  def domain do
    %{
      schema_version: 1,
      domain_version: "1.0.0",
      name: "Approval queue",
      source: %{
        source_table: "livebook_approvals",
        primary_key: :id,
        fields: [:id, :tenant_id, :state, :ready, :reviewed_by_id, :note, :eligible],
        columns: %{
          id: %{type: :integer},
          tenant_id: %{type: :integer},
          state: %{type: :string, write: %{updatable: true}},
          ready: %{type: :boolean},
          reviewed_by_id: %{type: :integer, write: %{updatable: true}},
          note: %{type: :string, write: %{updatable: true}},
          eligible: %{
            type: :boolean,
            internal: true,
            computed: %{
              kind: :predicate,
              expression: [:and, [[:eq, :state, "open"], [:eq, :ready, true]]]
            }
          }
        },
        associations: %{}
      },
      schemas: %{},
      joins: %{},
      tenant_required: true,
      writes: %{
        operations: %{
          update: %{enabled: true, require_filter: true, bulk: true, returning: :record}
        },
        scope: %{tenant: %{required: true, field: :tenant_id}},
        transitions: %{state: %{"open" => ["approved"], "approved" => []}}
      },
      capabilities: %{
        "approvals.approve" => %{operations: [:action, :update], action: :approve},
        "approvals.review" => %{operations: [:action, :update], action: :record_review}
      },
      actions: %{
        approve: %{
          type: :transition,
          label: "Approve",
          capability: "approvals.approve",
          transition: %{field: :state, from: "open", to: "approved"},
          preconditions: [{:ready, true}],
          selection: %{eligibility_field: :eligible},
          bulk: %{enabled: true},
          confirmation: %{required: true, message: "Approve the selected ready items?"},
          audit: %{event: "approval.approved", include_actor: true, include_target: true},
          execution: %{
            kind: :updato,
            operation: :update,
            set: %{state: "approved", reviewed_by_id: {:context, :actor_id}}
          }
        },
        record_review: %{
          type: :detail_action,
          label: "Record review",
          capability: "approvals.review",
          inputs: %{accepted: %{type: :boolean, required: true, discriminator: true}},
          variants: [
            %{
              id: :accepted,
              when: %{accepted: true},
              execution: %{kind: :updato, operation: :update, set: %{note: "Review accepted"}}
            },
            %{
              id: :needs_work,
              when: %{accepted: false},
              inputs: %{reason: %{type: :string, required: true}},
              execution: %{kind: :updato, operation: :update, set: %{note: {:input, :reason}}}
            }
          ]
        }
      }
    }
  end

  def connect! do
    {:ok, connection} =
      SelectoLivebooksNotebookBootstrap.repo_config()
      |> Keyword.put(:pool_size, 1)
      |> Postgrex.start_link()

    try do
      Postgrex.query!(
        connection,
        """
        CREATE TEMP TABLE livebook_approvals (
          id bigint PRIMARY KEY, tenant_id bigint NOT NULL, state text NOT NULL,
          ready boolean, reviewed_by_id bigint, note text
        )
        """,
        []
      )

      for [id, tenant_id, state, ready] <- [
            [1, 101, "open", true],
            [2, 101, "open", false],
            [3, 202, "open", true],
            [4, 101, "open", true],
            [5, 101, "open", nil]
          ] do
        Postgrex.query!(
          connection,
          "INSERT INTO livebook_approvals (id, tenant_id, state, ready) VALUES ($1, $2, $3, $4)",
          [id, tenant_id, state, ready]
        )
      end

      connection
    rescue
      error ->
        GenServer.stop(connection)
        reraise error, __STACKTRACE__
    end
  end
end
