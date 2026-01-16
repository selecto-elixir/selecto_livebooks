defmodule SelectoExamples.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  def change do
    create table(:customers) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :phone, :string
      add :tier, :string, default: "standard"  # standard, premium, vip
      add :company_name, :string
      add :address, :string
      add :city, :string
      add :region, :string
      add :postal_code, :string
      add :country, :string
      add :notes, :text
      add :preferences, :jsonb, default: fragment("'{}'::jsonb")
      add :active, :boolean, default: true
      add :verified_at, :utc_datetime

      timestamps()
    end

    create unique_index(:customers, [:email])
    create index(:customers, [:tier])
    create index(:customers, [:country])
    create index(:customers, [:active])
  end
end
