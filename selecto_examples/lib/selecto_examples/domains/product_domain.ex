defmodule SelectoExamples.Domains.ProductDomain do
  @moduledoc """
  Selecto domain configuration for Products.
  Used in the Selecto Guide examples.
  """

  def domain do
    %{
      name: "Products",
      source: %{
        source_table: "products",
        primary_key: :id,
        fields: [:id, :name, :sku, :description, :price, :cost, :stock_quantity,
                 :reorder_level, :weight, :active, :featured, :tags, :metadata,
                 :category_id, :supplier_id, :inserted_at, :updated_at],
        columns: %{
          id: %{type: :integer},
          name: %{type: :string, label: "Product Name"},
          sku: %{type: :string, label: "SKU"},
          description: %{type: :text, label: "Description"},
          price: %{type: :decimal, label: "Price", format: :currency},
          cost: %{type: :decimal, label: "Cost", format: :currency},
          stock_quantity: %{type: :integer, label: "Stock"},
          reorder_level: %{type: :integer, label: "Reorder Level"},
          weight: %{type: :decimal, label: "Weight"},
          active: %{type: :boolean, label: "Active?"},
          featured: %{type: :boolean, label: "Featured?"},
          tags: %{type: {:array, :string}, label: "Tags"},
          metadata: %{type: :jsonb, label: "Metadata"},
          category_id: %{type: :integer},
          supplier_id: %{type: :integer},
          inserted_at: %{type: :utc_datetime, label: "Created At"},
          updated_at: %{type: :utc_datetime, label: "Updated At"}
        },
        associations: %{
          category: %{field: :category, queryable: :categories, owner_key: :category_id, related_key: :id},
          supplier: %{field: :supplier, queryable: :suppliers, owner_key: :supplier_id, related_key: :id}
        }
      },
      schemas: %{
        categories: %{
          source_table: "categories",
          primary_key: :id,
          fields: [:id, :name, :description, :slug, :active],
          redact_fields: [],
          columns: %{
            id: %{type: :integer},
            name: %{type: :string, label: "Category Name"},
            description: %{type: :text},
            slug: %{type: :string},
            active: %{type: :boolean}
          }
        },
        suppliers: %{
          source_table: "suppliers",
          primary_key: :id,
          fields: [:id, :company_name, :contact_name, :email, :phone, :city, :country, :active],
          redact_fields: [],
          columns: %{
            id: %{type: :integer},
            company_name: %{type: :string, label: "Company"},
            contact_name: %{type: :string, label: "Contact"},
            email: %{type: :string},
            phone: %{type: :string},
            city: %{type: :string},
            country: %{type: :string},
            active: %{type: :boolean}
          }
        }
      },
      joins: %{
        category: %{
          name: "Category",
          type: :left,
          source: "categories",
          on: [%{left: "category_id", right: "id"}],
          fields: %{
            name: %{type: :string, label: "Category Name"},
            description: %{type: :text, label: "Category Description"}
          }
        },
        supplier: %{
          name: "Supplier",
          type: :left,
          source: "suppliers",
          on: [%{left: "supplier_id", right: "id"}],
          fields: %{
            company_name: %{type: :string, label: "Supplier Name"},
            contact_name: %{type: :string, label: "Supplier Contact"},
            country: %{type: :string, label: "Supplier Country"}
          }
        }
      },
      default_selected: ["name", "sku", "price", "stock_quantity"],
      default_order_by: [{"name", :asc}]
    }
  end
end
