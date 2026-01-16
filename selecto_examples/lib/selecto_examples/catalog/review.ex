defmodule SelectoExamples.Catalog.Review do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reviews" do
    field :rating, :integer
    field :title, :string
    field :body, :string
    field :helpful_count, :integer, default: 0
    field :verified_purchase, :boolean, default: false

    belongs_to :product, SelectoExamples.Catalog.Product
    belongs_to :customer, SelectoExamples.Sales.Customer

    timestamps()
  end

  def changeset(review, attrs) do
    review
    |> cast(attrs, [:rating, :title, :body, :helpful_count, :verified_purchase,
                     :product_id, :customer_id])
    |> validate_required([:rating, :product_id, :customer_id])
    |> validate_inclusion(:rating, 1..5)
    |> unique_constraint([:product_id, :customer_id])
    |> foreign_key_constraint(:product_id)
    |> foreign_key_constraint(:customer_id)
  end
end
