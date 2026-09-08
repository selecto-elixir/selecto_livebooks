defmodule SelectoLivebooks.Domains.OrderItemDomain do
  @moduledoc """
  Selecto domain configuration for Order Items.
  Used for line-level joins, subselects, and aggregate examples.
  """

  def domain do
    %{
      name: "OrderItems",
      source: %{
        source_table: "order_items",
        primary_key: :id,
        fields: [
          :id,
          :quantity,
          :unit_price,
          :discount,
          :line_total,
          :line_number,
          :order_id,
          :product_id
        ],
        redact_fields: [],
        columns: %{
          id: %{type: :integer},
          quantity: %{type: :integer},
          unit_price: %{type: :decimal},
          discount: %{type: :decimal},
          line_total: %{type: :decimal},
          line_number: %{type: :integer},
          order_id: %{type: :integer},
          product_id: %{type: :integer}
        },
        associations: %{
          order: %{field: :order, queryable: :orders, owner_key: :order_id, related_key: :id},
          product: %{
            field: :product,
            queryable: :products,
            owner_key: :product_id,
            related_key: :id
          }
        }
      },
      schemas: %{
        orders: %{
          source_table: "orders",
          primary_key: :id,
          fields: [:id, :order_number, :status, :shipping_country, :inserted_at],
          redact_fields: [],
          columns: %{
            id: %{type: :integer},
            order_number: %{type: :string},
            status: %{type: :string},
            shipping_country: %{type: :string},
            inserted_at: %{type: :utc_datetime}
          }
        },
        products: %{
          source_table: "products",
          primary_key: :id,
          fields: [:id, :name, :sku, :price],
          redact_fields: [],
          columns: %{
            id: %{type: :integer},
            name: %{type: :string},
            sku: %{type: :string},
            price: %{type: :decimal}
          }
        }
      },
      joins: %{
        order: %{
          name: "Order",
          type: :left,
          source: "orders",
          on: [%{left: "order_id", right: "id"}],
          fields: %{
            order_number: %{type: :string},
            status: %{type: :string},
            shipping_country: %{type: :string},
            inserted_at: %{type: :utc_datetime}
          }
        },
        product: %{
          name: "Product",
          type: :left,
          source: "products",
          on: [%{left: "product_id", right: "id"}],
          fields: %{
            name: %{type: :string},
            sku: %{type: :string},
            price: %{type: :decimal}
          }
        }
      },
      default_selected: ["product.name", "quantity", "unit_price", "line_total"],
      default_order_by: [{"id", :asc}]
    }
  end
end
