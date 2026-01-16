defmodule SelectoExamples.Sales.OrderItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "order_items" do
    field :quantity, :integer, default: 1
    field :unit_price, :decimal
    field :discount, :decimal, default: Decimal.new("0")
    field :line_total, :decimal
    field :line_number, :integer

    belongs_to :order, SelectoExamples.Sales.Order
    belongs_to :product, SelectoExamples.Catalog.Product

    timestamps()
  end

  def changeset(order_item, attrs) do
    order_item
    |> cast(attrs, [:quantity, :unit_price, :discount, :line_total, :line_number,
                     :order_id, :product_id])
    |> validate_required([:quantity, :unit_price, :line_total, :order_id, :product_id])
    |> validate_number(:quantity, greater_than: 0)
    |> unique_constraint([:order_id, :product_id])
    |> foreign_key_constraint(:order_id)
    |> foreign_key_constraint(:product_id)
  end
end
