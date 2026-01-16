defmodule SelectoExamples.Repo.Migrations.CreateEmployees do
  use Ecto.Migration

  def change do
    # Employees table for hierarchical data examples
    create table(:employees) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :email, :string, null: false
      add :title, :string
      add :department, :string
      add :hire_date, :date
      add :salary, :decimal, precision: 12, scale: 2
      add :active, :boolean, default: true
      add :manager_id, references(:employees, on_delete: :nilify_all)

      timestamps()
    end

    create unique_index(:employees, [:email])
    create index(:employees, [:manager_id])
    create index(:employees, [:department])
  end
end
