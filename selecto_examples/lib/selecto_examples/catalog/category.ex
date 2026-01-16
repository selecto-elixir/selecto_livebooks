defmodule SelectoExamples.Catalog.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :description, :string
    field :slug, :string
    field :active, :boolean, default: true

    has_many :products, SelectoExamples.Catalog.Product

    timestamps()
  end

  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description, :slug, :active])
    |> validate_required([:name])
    |> unique_constraint(:slug)
  end
end
