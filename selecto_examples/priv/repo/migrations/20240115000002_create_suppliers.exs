defmodule SelectoExamples.Repo.Migrations.CreateSuppliers do
  use Ecto.Migration

  def change do
    create table(:suppliers) do
      add :company_name, :string, null: false
      add :contact_name, :string
      add :contact_title, :string
      add :email, :string
      add :phone, :string
      add :address, :string
      add :city, :string
      add :region, :string
      add :postal_code, :string
      add :country, :string
      add :active, :boolean, default: true

      timestamps()
    end

    create index(:suppliers, [:company_name])
    create index(:suppliers, [:country])
  end
end
