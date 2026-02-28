# Selecto Examples

`selecto_examples` is the runnable app used by the `selecto_livebooks` guide.
It provides a Postgres dataset plus domain definitions for trying Selecto
queries interactively.

## What Is Included

- Ecto schemas for products, orders, customers, employees, tags, and reviews
- Migrations and seed data
- Domain modules for Selecto examples
- Livebook notebooks under:
  - `livebooks/selecto_guide_examples.livemd`
  - `livebooks/selecto_updato_feature_tour.livemd`
  - `livebooks/selecto_selection_shapes_subselects_pivots.livemd`
  - `livebooks/selecto_filtering_system_workbook.livemd`
  - `livebooks/selecto_group_by_aggregates_workbook.livemd`
  - `livebooks/selecto_ctes_workbook.livemd`
  - `livebooks/selecto_other_joins_workbook.livemd`
  - `livebooks/selecto_window_functions_workbook.livemd`
  - `livebooks/selecto_json_operations_workbook.livemd`
  - `livebooks/selecto_array_unnest_lateral_workbook.livemd`
  - `livebooks/selecto_set_operations_workbook.livemd`
  - `livebooks/selecto_case_expressions_workbook.livemd`
  - `livebooks/selecto_values_lookup_workbook.livemd`
  - `livebooks/selecto_output_formats_execution_workbook.livemd`
  - `livebooks/selecto_domain_join_types_workbook.livemd`

## Requirements

- Elixir `~> 1.17`
- PostgreSQL `13+`

## Setup

```bash
mix deps.get
mix setup
```

`mix setup` runs:

1. `deps.get`
2. `ecto.create`
3. `ecto.migrate`
4. `priv/repo/seeds.exs`

## Run Tests

```bash
mix test
```

## Open the Livebook

From repo root:

```bash
livebook server
```

Then open:

`selecto_examples/livebooks/selecto_guide_examples.livemd`

or:

`selecto_examples/livebooks/selecto_updato_feature_tour.livemd`

or:

`selecto_examples/livebooks/selecto_selection_shapes_subselects_pivots.livemd`

or any focused workbook under `selecto_examples/livebooks/`:

- `selecto_filtering_system_workbook.livemd`
- `selecto_group_by_aggregates_workbook.livemd`
- `selecto_ctes_workbook.livemd`
- `selecto_other_joins_workbook.livemd`
- `selecto_window_functions_workbook.livemd`
- `selecto_json_operations_workbook.livemd`
- `selecto_array_unnest_lateral_workbook.livemd`
- `selecto_set_operations_workbook.livemd`
- `selecto_case_expressions_workbook.livemd`
- `selecto_values_lookup_workbook.livemd`
- `selecto_output_formats_execution_workbook.livemd`
- `selecto_domain_join_types_workbook.livemd`

## Notes

- Most livebooks install `selecto` from Hex (`>= 0.3.4 and < 0.4.0`).
- The `selecto_updato` tour keeps its package source dynamic until `selecto_updato`
  is published on Hex.
