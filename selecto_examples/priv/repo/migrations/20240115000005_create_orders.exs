defmodule SelectoExamples.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :order_number, :string, null: false
      add :status, :string, default: "pending"  # pending, processing, shipped, delivered, cancelled
      add :subtotal, :decimal, precision: 12, scale: 2, null: false, default: 0
      add :tax, :decimal, precision: 10, scale: 2, default: 0
      add :shipping, :decimal, precision: 10, scale: 2, default: 0
      add :discount, :decimal, precision: 10, scale: 2, default: 0
      add :total, :decimal, precision: 12, scale: 2, null: false
      add :shipping_address, :string
      add :shipping_city, :string
      add :shipping_region, :string
      add :shipping_postal_code, :string
      add :shipping_country, :string
      add :notes, :text
      add :shipped_at, :utc_datetime
      add :delivered_at, :utc_datetime
      add :customer_id, references(:customers, on_delete: :restrict), null: false

      timestamps()
    end

    create unique_index(:orders, [:order_number])
    create index(:orders, [:customer_id])
    create index(:orders, [:status])
    create index(:orders, [:inserted_at])
    create index(:orders, [:total])
  end
end
