defmodule SelectoLivebooks.DomainExtensionFixture do
  @moduledoc false

  def customer_order_summary_domain do
    SelectoLivebooks.Domains.CustomerDomain.domain()
    |> put_in([:name], "customer_order_summary_fixture")
    |> put_in([:source, :source_table], "customer_order_summary_fixture")
    |> put_in([:source, :source_kind], :view)
    |> put_in([:source, :readonly], true)
    |> put_in([:source, :fields], [:id, :name, :tier, :order_count, :gross_total])
    |> put_in([:source, :columns], %{
      id: %{type: :integer},
      name: %{type: :string},
      tier: %{type: :string},
      order_count: %{type: :integer},
      gross_total: %{type: :decimal}
    })
  end
end
