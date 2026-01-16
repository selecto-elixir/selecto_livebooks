defmodule SelectoExamples.Domains.EmployeeDomain do
  @moduledoc """
  Selecto domain configuration for Employees.
  Used for hierarchical data and recursive CTE examples.
  """

  def domain do
    %{
      name: "Employees",
      source: %{
        source_table: "employees",
        primary_key: :id,
        fields: [:id, :first_name, :last_name, :email, :title, :department,
                 :hire_date, :salary, :active, :manager_id, :inserted_at, :updated_at],
        columns: %{
          id: %{type: :integer},
          first_name: %{type: :string, label: "First Name"},
          last_name: %{type: :string, label: "Last Name"},
          email: %{type: :string, label: "Email"},
          title: %{type: :string, label: "Title"},
          department: %{type: :string, label: "Department"},
          hire_date: %{type: :date, label: "Hire Date"},
          salary: %{type: :decimal, label: "Salary", format: :currency},
          active: %{type: :boolean, label: "Active?"},
          manager_id: %{type: :integer},
          inserted_at: %{type: :utc_datetime, label: "Created At"},
          updated_at: %{type: :utc_datetime, label: "Updated At"}
        },
        associations: %{
          manager: %{queryable: :employees, owner_key: :manager_id, related_key: :id}
        }
      },
      schemas: %{
        employees: %{
          source_table: "employees",
          primary_key: :id,
          fields: [:id, :first_name, :last_name, :email, :title, :department,
                   :hire_date, :salary, :active, :manager_id],
          columns: %{
            id: %{type: :integer},
            first_name: %{type: :string},
            last_name: %{type: :string},
            email: %{type: :string},
            title: %{type: :string},
            department: %{type: :string},
            hire_date: %{type: :date},
            salary: %{type: :decimal},
            active: %{type: :boolean},
            manager_id: %{type: :integer}
          }
        }
      },
      joins: %{
        manager: %{
          name: "Manager",
          type: :left,
          source: "employees",
          on: [%{left: "manager_id", right: "id"}],
          fields: %{
            first_name: %{type: :string, label: "Manager First Name"},
            last_name: %{type: :string, label: "Manager Last Name"},
            email: %{type: :string, label: "Manager Email"}
          }
        }
      },
      default_selected: ["first_name", "last_name", "title", "department"],
      default_order_by: [{"last_name", :asc}, {"first_name", :asc}]
    }
  end
end
