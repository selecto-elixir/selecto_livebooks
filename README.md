# Selecto Livebooks

Interactive Livebook examples demonstrating the Selecto SQL query builder.

## Contents

- `selecto_examples/` - Elixir project with Ecto schemas and seed data
- `selecto_examples/livebooks/` - Livebook notebooks

## Setup

1. Navigate to the project directory:
   ```bash
   cd selecto_examples
   ```

2. Install dependencies and set up the database:
   ```bash
   mix setup
   ```

   This will:
   - Install dependencies
   - Create the PostgreSQL database
   - Run migrations
   - Seed sample data

3. Open the Livebook:
   - Start Livebook: `livebook server`
   - Open `selecto_examples/livebooks/selecto_guide_examples.livemd`

## Database Schema

The example database includes an e-commerce schema:

- **Categories** - Product categories
- **Suppliers** - Product suppliers
- **Products** - Products with category/supplier relationships
- **Tags** - Product tags (many-to-many)
- **Customers** - Customer accounts with tiers
- **Orders** - Customer orders
- **Order Items** - Line items for orders
- **Employees** - Employee hierarchy for recursive CTE examples
- **Reviews** - Product reviews

## Sample Data

The seed script creates:
- 8 categories
- 8 suppliers
- 35 products
- 8 tags
- 15 customers
- 200 orders with items
- 15 employees in a hierarchy
- ~100 reviews

## Livebook Examples

The main Livebook demonstrates:

1. Basic query building
2. Filtering with various operators
3. Sorting and pagination
4. Aggregates and GROUP BY
5. Joins and associations
6. Composable query patterns
7. Output format transformations
8. A complete sales dashboard

## Requirements

- Elixir 1.17+
- PostgreSQL 13+
- Livebook 0.12+
