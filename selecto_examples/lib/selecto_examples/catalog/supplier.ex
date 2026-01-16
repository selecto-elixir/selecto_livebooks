defmodule SelectoExamples.Catalog.Supplier do
  use Ecto.Schema
  import Ecto.Changeset

  schema "suppliers" do
    field :company_name, :string
    field :contact_name, :string
    field :contact_title, :string
    field :email, :string
    field :phone, :string
    field :address, :string
    field :city, :string
    field :region, :string
    field :postal_code, :string
    field :country, :string
    field :active, :boolean, default: true

    has_many :products, SelectoExamples.Catalog.Product

    timestamps()
  end

  def changeset(supplier, attrs) do
    supplier
    |> cast(attrs, [:company_name, :contact_name, :contact_title, :email, :phone,
                     :address, :city, :region, :postal_code, :country, :active])
    |> validate_required([:company_name])
  end
end
