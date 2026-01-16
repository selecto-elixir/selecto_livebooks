defmodule SelectoExamples.Sales.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "customers" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :tier, :string, default: "standard"
    field :company_name, :string
    field :address, :string
    field :city, :string
    field :region, :string
    field :postal_code, :string
    field :country, :string
    field :notes, :string
    field :preferences, :map, default: %{}
    field :active, :boolean, default: true
    field :verified_at, :utc_datetime

    has_many :orders, SelectoExamples.Sales.Order
    has_many :reviews, SelectoExamples.Catalog.Review

    timestamps()
  end

  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [:name, :email, :phone, :tier, :company_name, :address,
                     :city, :region, :postal_code, :country, :notes, :preferences,
                     :active, :verified_at])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> validate_inclusion(:tier, ["standard", "premium", "vip"])
    |> unique_constraint(:email)
  end
end
