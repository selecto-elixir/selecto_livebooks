defmodule SelectoExamples.Repo.Migrations.CreateReviews do
  use Ecto.Migration

  def change do
    create table(:reviews) do
      add :rating, :integer, null: false  # 1-5
      add :title, :string
      add :body, :text
      add :helpful_count, :integer, default: 0
      add :verified_purchase, :boolean, default: false
      add :product_id, references(:products, on_delete: :delete_all), null: false
      add :customer_id, references(:customers, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:reviews, [:product_id])
    create index(:reviews, [:customer_id])
    create index(:reviews, [:rating])
    create unique_index(:reviews, [:product_id, :customer_id])
  end
end
