defmodule SelectoExamples.Domains.OrderDomain do
  @moduledoc """
  Selecto domain configuration for Orders.
  Used in the Selecto Guide examples.
  """

  def domain do
    %{
      name: "Orders",
      source: %{
        source_table: "orders",
        primary_key: :id,
        fields: [:id, :order_number, :status, :subtotal, :tax, :shipping, :discount,
                 :total, :shipping_address, :shipping_city, :shipping_region,
                 :shipping_postal_code, :shipping_country, :notes,
                 :shipped_at, :delivered_at, :customer_id, :inserted_at, :updated_at],
        columns: %{
          id: %{type: :integer},
          order_number: %{type: :string, label: "Order #"},
          status: %{type: :string, label: "Status"},
          subtotal: %{type: :decimal, label: "Subtotal", format: :currency},
          tax: %{type: :decimal, label: "Tax", format: :currency},
          shipping: %{type: :decimal, label: "Shipping", format: :currency},
          discount: %{type: :decimal, label: "Discount", format: :currency},
          total: %{type: :decimal, label: "Total", format: :currency},
          shipping_address: %{type: :string, label: "Ship To Address"},
          shipping_city: %{type: :string, label: "Ship To City"},
          shipping_region: %{type: :string, label: "Ship To Region"},
          shipping_postal_code: %{type: :string, label: "Ship To Postal Code"},
          shipping_country: %{type: :string, label: "Ship To Country"},
          notes: %{type: :text},
          shipped_at: %{type: :utc_datetime, label: "Shipped Date"},
          delivered_at: %{type: :utc_datetime, label: "Delivered Date"},
          customer_id: %{type: :integer},
          inserted_at: %{type: :utc_datetime, label: "Order Date"},
          updated_at: %{type: :utc_datetime}
        },
        associations: %{
          customer: %{queryable: :customers, owner_key: :customer_id, related_key: :id},
          order_items: %{queryable: :order_items, owner_key: :id, related_key: :order_id}
        }
      },
      schemas: %{
        customers: %{
          source_table: "customers",
          primary_key: :id,
          fields: [:id, :name, :email, :phone, :tier, :company_name, :city, :country, :active],
          columns: %{
            id: %{type: :integer},
            name: %{type: :string, label: "Customer Name"},
            email: %{type: :string},
            phone: %{type: :string},
            tier: %{type: :string, label: "Customer Tier"},
            company_name: %{type: :string},
            city: %{type: :string},
            country: %{type: :string},
            active: %{type: :boolean}
          }
        },
        order_items: %{
          source_table: "order_items",
          primary_key: :id,
          fields: [:id, :quantity, :unit_price, :discount, :line_total, :line_number,
                   :order_id, :product_id],
          columns: %{
            id: %{type: :integer},
            quantity: %{type: :integer},
            unit_price: %{type: :decimal},
            discount: %{type: :decimal},
            line_total: %{type: :decimal},
            line_number: %{type: :integer},
            order_id: %{type: :integer},
            product_id: %{type: :integer}
          }
        },
        products: %{
          source_table: "products",
          primary_key: :id,
          fields: [:id, :name, :sku, :price, :category_id],
          columns: %{
            id: %{type: :integer},
            name: %{type: :string},
            sku: %{type: :string},
            price: %{type: :decimal},
            category_id: %{type: :integer}
          }
        }
      },
      joins: %{
        customer: %{
          name: "Customer",
          type: :left,
          source: "customers",
          on: [%{left: "customer_id", right: "id"}],
          fields: %{
            name: %{type: :string, label: "Customer Name"},
            email: %{type: :string, label: "Customer Email"},
            tier: %{type: :string, label: "Customer Tier"},
            country: %{type: :string, label: "Customer Country"}
          }
        },
        order_items: %{
          name: "Order Items",
          type: :left,
          source: "order_items",
          on: [%{left: "id", right: "order_id"}],
          fields: %{
            quantity: %{type: :integer},
            unit_price: %{type: :decimal},
            line_total: %{type: :decimal}
          }
        }
      },
      default_selected: ["order_number", "status", "total", "customer.name", "inserted_at"],
      default_order_by: [{"inserted_at", :desc}]
    }
  end
end
