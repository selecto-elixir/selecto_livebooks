defmodule SelectoExamples.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false
      add :description, :text
      add :slug, :string
      add :active, :boolean, default: true

      timestamps()
    end

    create unique_index(:categories, [:slug])
    create index(:categories, [:name])
  end
end
