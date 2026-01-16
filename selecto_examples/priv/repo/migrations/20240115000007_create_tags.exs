defmodule SelectoExamples.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :text

      timestamps()
    end

    create unique_index(:tags, [:slug])
    create index(:tags, [:name])

    # Many-to-many join table for products and tags
    create table(:product_tags, primary_key: false) do
      add :product_id, references(:products, on_delete: :delete_all), null: false
      add :tag_id, references(:tags, on_delete: :delete_all), null: false
    end

    create unique_index(:product_tags, [:product_id, :tag_id])
    create index(:product_tags, [:tag_id])
  end
end
