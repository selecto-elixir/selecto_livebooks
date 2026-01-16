defmodule SelectoExamples.Sales.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :order_number, :string
    field :status, :string, default: "pending"
    field :subtotal, :decimal
    field :tax, :decimal
    field :shipping, :decimal
    field :discount, :decimal
    field :total, :decimal
    field :shipping_address, :string
    field :shipping_city, :string
    field :shipping_region, :string
    field :shipping_postal_code, :string
    field :shipping_country, :string
    field :notes, :string
    field :shipped_at, :utc_datetime
    field :delivered_at, :utc_datetime

    belongs_to :customer, SelectoExamples.Sales.Customer
    has_many :order_items, SelectoExamples.Sales.OrderItem

    timestamps()
  end

  def changeset(order, attrs) do
    order
    |> cast(attrs, [:order_number, :status, :subtotal, :tax, :shipping, :discount,
                     :total, :shipping_address, :shipping_city, :shipping_region,
                     :shipping_postal_code, :shipping_country, :notes,
                     :shipped_at, :delivered_at, :customer_id])
    |> validate_required([:order_number, :total, :customer_id])
    |> validate_inclusion(:status, ["pending", "processing", "shipped", "delivered", "cancelled"])
    |> unique_constraint(:order_number)
    |> foreign_key_constraint(:customer_id)
  end
end
