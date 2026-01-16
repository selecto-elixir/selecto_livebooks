defmodule SelectoExamples.Repo.Migrations.CreateOrderItems do
  use Ecto.Migration

  def change do
    create table(:order_items) do
      add :quantity, :integer, null: false, default: 1
      add :unit_price, :decimal, precision: 10, scale: 2, null: false
      add :discount, :decimal, precision: 10, scale: 2, default: 0
      add :line_total, :decimal, precision: 12, scale: 2, null: false
      add :line_number, :integer
      add :order_id, references(:orders, on_delete: :delete_all), null: false
      add :product_id, references(:products, on_delete: :restrict), null: false

      timestamps()
    end

    create index(:order_items, [:order_id])
    create index(:order_items, [:product_id])
    create unique_index(:order_items, [:order_id, :product_id])
  end
end
