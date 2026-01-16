defmodule SelectoExamples.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string, null: false
      add :sku, :string, null: false
      add :description, :text
      add :price, :decimal, precision: 10, scale: 2, null: false
      add :cost, :decimal, precision: 10, scale: 2
      add :stock_quantity, :integer, default: 0
      add :reorder_level, :integer, default: 10
      add :weight, :decimal, precision: 8, scale: 2
      add :active, :boolean, default: true
      add :featured, :boolean, default: false
      add :tags, {:array, :string}, default: []
      add :metadata, :jsonb, default: fragment("'{}'::jsonb")
      add :category_id, references(:categories, on_delete: :restrict)
      add :supplier_id, references(:suppliers, on_delete: :restrict)

      timestamps()
    end

    create unique_index(:products, [:sku])
    create index(:products, [:category_id])
    create index(:products, [:supplier_id])
    create index(:products, [:active])
    create index(:products, [:price])
    create index(:products, [:tags], using: :gin)
  end
end
