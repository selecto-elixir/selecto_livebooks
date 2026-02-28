# Selecto Livebooks

`selecto_livebooks` is a standalone example repo for learning and testing
the Selecto query builder in a real Elixir project and Livebook.

It includes:

- `selecto_examples/` - an Ecto app with schemas, migrations, and seed data
- `selecto_examples/livebooks/selecto_guide_examples.livemd` - an interactive
  end-to-end guide covering core and advanced Selecto features
- `selecto_examples/livebooks/selecto_updato_feature_tour.livemd` - a
  full write-path tour covering the complete SelectoUpdato public API
- `selecto_examples/livebooks/selecto_selection_shapes_subselects_pivots.livemd` -
  focused examples for selection patterns, selection shapes, subselects, and
  pivoted query roots

## What This Repo Does

The examples are centered on an e-commerce-style dataset and demonstrate:

1. Domain configuration (`source`, `schemas`, `joins`)
2. Query building with `select`, `filter`, `order_by`, `group_by`
3. Joins (including dynamic joins and parameterized join aliases)
4. Pivoting, subselects, CTEs, recursive CTEs, set operations
5. Window functions, JSON/array operations, CASE expressions, VALUES
6. Different execution/output formats

## Requirements

- Elixir `~> 1.17`
- PostgreSQL `13+`
- Livebook `0.12+`

## Quick Start

1. Go to the example app:
   ```bash
   cd selecto_examples
   ```
2. Install deps and prepare the database:
   ```bash
   mix setup
   ```
3. Start Livebook:
   ```bash
   livebook server
   ```
4. Open one notebook:
   - `selecto_examples/livebooks/selecto_guide_examples.livemd`
   - `selecto_examples/livebooks/selecto_selection_shapes_subselects_pivots.livemd`

## Dependency Source

`selecto_examples` and the Livebook install `selecto` directly from GitHub
(`seeken/selecto`, branch `main`) so examples track ongoing development.

## Database Model

The seed data creates:

- categories
- suppliers
- products
- tags
- customers
- orders
- order_items
- employees (hierarchy)
- reviews
