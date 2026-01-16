defmodule SelectoExamples.Domains.CustomerDomain do
  @moduledoc """
  Selecto domain configuration for Customers.
  Used in the Selecto Guide examples.
  """

  def domain do
    %{
      name: "Customers",
      source: %{
        source_table: "customers",
        primary_key: :id,
        fields: [:id, :name, :email, :phone, :tier, :company_name, :address,
                 :city, :region, :postal_code, :country, :notes, :preferences,
                 :active, :verified_at, :inserted_at, :updated_at],
        columns: %{
          id: %{type: :integer},
          name: %{type: :string, label: "Customer Name"},
          email: %{type: :string, label: "Email"},
          phone: %{type: :string, label: "Phone"},
          tier: %{type: :string, label: "Tier"},
          company_name: %{type: :string, label: "Company"},
          address: %{type: :string, label: "Address"},
          city: %{type: :string, label: "City"},
          region: %{type: :string, label: "Region"},
          postal_code: %{type: :string, label: "Postal Code"},
          country: %{type: :string, label: "Country"},
          notes: %{type: :text, label: "Notes"},
          preferences: %{type: :jsonb, label: "Preferences"},
          active: %{type: :boolean, label: "Active?"},
          verified_at: %{type: :utc_datetime, label: "Verified At"},
          inserted_at: %{type: :utc_datetime, label: "Created At"},
          updated_at: %{type: :utc_datetime, label: "Updated At"}
        }
      },
      joins: %{},
      default_selected: ["name", "email", "tier", "country", "active"],
      default_order_by: [{"name", :asc}]
    }
  end
end
