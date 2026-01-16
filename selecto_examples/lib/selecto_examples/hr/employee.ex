defmodule SelectoExamples.Hr.Employee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "employees" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :title, :string
    field :department, :string
    field :hire_date, :date
    field :salary, :decimal
    field :active, :boolean, default: true

    belongs_to :manager, SelectoExamples.Hr.Employee
    has_many :direct_reports, SelectoExamples.Hr.Employee, foreign_key: :manager_id

    timestamps()
  end

  def changeset(employee, attrs) do
    employee
    |> cast(attrs, [:first_name, :last_name, :email, :title, :department,
                     :hire_date, :salary, :active, :manager_id])
    |> validate_required([:first_name, :last_name, :email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> foreign_key_constraint(:manager_id)
  end
end
