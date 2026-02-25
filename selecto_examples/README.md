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

## Notes

- `selecto` is pulled from GitHub (`seeken/selecto`, branch `main`) to track
  current development.
