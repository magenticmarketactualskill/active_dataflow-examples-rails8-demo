# Rails 8 Demo App - ActiveDataFlow Example

This is a demonstration Rails 8 application showcasing ActiveDataFlow functionality. The app demonstrates a product catalog synchronization use case with data transformation.

## Overview

This demo app illustrates how to integrate ActiveDataFlow into a Rails application to:
- Read data from a source table (products)
- Transform the data (price conversion, slug generation)
- Write to a destination table (product_exports)
- Monitor DataFlow execution through a web interface

## Requirements

- Ruby 2.7 or higher
- Rails 8.1+
- SQLite3

## Setup Instructions

### 1. Clone the Repository

If you're cloning the parent repository with submodules:

```bash
git clone --recursive https://github.com/yourusername/active_data_flow.git
cd active_data_flow/submodules/examples/rails8-demo
```

Or if you already have the repository:

```bash
cd active_data_flow/submodules/examples/rails8-demo
```

### 2. Install Dependencies

```bash
bundle install
```

### 3. Setup Database

Create the database, run migrations, and load seed data:

```bash
rails db:create
rails db:migrate
rails db:seed
```

This will create:
- 15 sample products (12 active, 3 inactive)
- Database tables for products and product_exports

### 4. Start the Server

```bash
rails server
```

The application will be available at `http://localhost:3000`

## Application Structure

### Models

- **Product**: Source table containing product catalog data
  - Fields: name, sku, price, category, active
  
- **ProductExport**: Destination table for transformed product data
  - Fields: product_id, name, sku, price_cents, category_slug, exported_at

### DataFlow

- **ProductSyncFlow**: Demonstrates data transformation
  - Filters active products only
  - Converts price to cents (multiply by 100)
  - Generates category slugs using parameterize
  - Adds export timestamp

### Controllers & Views

- **ProductsController**: Display source products
- **ProductExportsController**: Display exported products

## Usage

### View Products

Visit `http://localhost:3000` to see the list of products in the catalog.

### View Exports

Visit `http://localhost:3000/product_exports` to see products that have been exported.

### Trigger DataFlow (TODO)

Once ActiveDataFlow gems are fully implemented, you can trigger the DataFlow:

```bash
curl -X POST http://localhost:3000/active_data_flow/data_flows/heartbeat
```

Or visit the DataFlows dashboard at `http://localhost:3000/active_data_flow/data_flows`

## Development Status

**Note**: This demo app is currently in development. The ActiveDataFlow gems are being implemented and some features are temporarily disabled:

- ActiveDataFlow Rails engine mounting (commented out in routes)
- DataFlow configuration seeding (commented out in seeds)
- ActiveDataFlow initializer configuration (commented out)

These will be enabled once the core ActiveDataFlow gems are complete.

## Use Case: Product Catalog Sync

This demo implements a realistic e-commerce scenario where:

1. Products are maintained in a main catalog table
2. Active products need to be synced to an export table for external systems
3. Data transformation is required during sync:
   - Price conversion (dollars to cents)
   - Category normalization (text to slug)
   - Timestamp tracking

### Data Flow

```
Products Table (source)
  ↓ Filter: active = true
  ↓ Transform: price → price_cents, category → slug
  ↓ Add: exported_at timestamp
ProductExports Table (sink)
```

## Troubleshooting

### Database Issues

If you encounter database issues, try resetting:

```bash
rails db:drop db:create db:migrate db:seed
```

### Missing Dependencies

Ensure all gems are installed:

```bash
bundle install
```

### Port Already in Use

If port 3000 is already in use, start the server on a different port:

```bash
rails server -p 3001
```

## Project Structure

```
app/
├── controllers/
│   ├── products_controller.rb
│   └── product_exports_controller.rb
├── models/
│   ├── product.rb
│   └── product_export.rb
├── data_flows/
│   └── product_sync_flow.rb
└── views/
    ├── products/
    └── product_exports/
config/
├── routes.rb
└── initializers/
    └── active_data_flow.rb
db/
├── migrate/
│   ├── *_create_products.rb
│   └── *_create_product_exports.rb
└── seeds.rb
```

## Related Documentation

- [ActiveDataFlow Parent Repository](../../../)
- [ActiveDataFlow Requirements](../../../.kiro/specs/requirements.md)
- [ActiveDataFlow Design](../../../.kiro/specs/design.md)

## License

This demo application is part of the ActiveDataFlow project.
