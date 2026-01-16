defmodule SelectoExamples.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :sku, :string
    field :description, :string
    field :price, :decimal
    field :cost, :decimal
    field :stock_quantity, :integer, default: 0
    field :reorder_level, :integer, default: 10
    field :weight, :decimal
    field :active, :boolean, default: true
    field :featured, :boolean, default: false
    field :tags, {:array, :string}, default: []
    field :metadata, :map, default: %{}

    belongs_to :category, SelectoExamples.Catalog.Category
    belongs_to :supplier, SelectoExamples.Catalog.Supplier
    has_many :order_items, SelectoExamples.Sales.OrderItem
    has_many :reviews, SelectoExamples.Catalog.Review
    many_to_many :product_tags, SelectoExamples.Catalog.Tag, join_through: "product_tags"

    timestamps()
  end

  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :sku, :description, :price, :cost, :stock_quantity,
                     :reorder_level, :weight, :active, :featured, :tags, :metadata,
                     :category_id, :supplier_id])
    |> validate_required([:name, :sku, :price])
    |> validate_number(:price, greater_than: 0)
    |> validate_number(:stock_quantity, greater_than_or_equal_to: 0)
    |> unique_constraint(:sku)
    |> foreign_key_constraint(:category_id)
    |> foreign_key_constraint(:supplier_id)
  end
end
