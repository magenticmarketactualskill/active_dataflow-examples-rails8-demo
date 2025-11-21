# Glossary - Rails 8 Demo Application

## System Components

- **Rails_App**: The Rails 8 web application that hosts the demo
- **Web_Interface**: The browser-based user interface for viewing products and exports

## Data Entities

- **Product_Catalog**: The source database table containing product information
- **Product_Export_Table**: The destination database table containing transformed product data
- **Active_Product**: A product record where the active field equals true

## DataFlow Components

- **DataFlow**: An ActiveDataFlow process that reads, transforms, and writes data
- **Product_Sync_Flow**: The specific DataFlow implementation that syncs products to exports
- **Heartbeat_Endpoint**: An HTTP endpoint that triggers DataFlow execution

## Data Transformations

- **Price_Cents**: Product price converted from dollars to cents (multiplied by 100)
- **Category_Slug**: A URL-friendly version of the category name

## Trigger Generator Components

### Core Components

- **Trigger_Generator**: A Rails generator tool that creates and manages triggers for DataFlow execution
- **Trigger**: An automated mechanism that initiates DataFlow execution based on specific conditions or events

### Trigger Types

- **Scheduled_Trigger**: A trigger that executes a DataFlow at specified time intervals using Rails Solid Queue recurring jobs
- **Webhook_Trigger**: A trigger that executes a DataFlow when an HTTP POST request is received at a specific endpoint
- **Database_Trigger**: A trigger that executes a DataFlow when database events occur (create, update, delete) on specific models
- **Event_Trigger**: A trigger that executes a DataFlow when application events are published via ActiveSupport::Notifications

### Configuration Components

- **Schedule_Expression**: A time-based expression defining when a Scheduled_Trigger should execute (e.g., "every 5 minutes", "at 3am every day")
- **Webhook_Endpoint**: The HTTP URL path where a Webhook_Trigger accepts requests
- **Callback_Event**: The ActiveRecord lifecycle event that activates a Database_Trigger (after_create, after_update, after_destroy, after_commit)
- **Event_Subscription**: The registration of an Event_Trigger to listen for specific application events

### Execution Components

- **Trigger_Execution**: A single instance of a trigger running and invoking its associated DataFlow
- **Retry_Logic**: The mechanism that automatically re-attempts failed DataFlow executions with exponential backoff
- **Error_Handler**: The component that catches and processes exceptions during trigger execution
- **Execution_Metrics**: Performance and status data collected during trigger execution (execution time, success/failure, resource usage)

## Model Components

### Models

- **Product_Model**: The ActiveRecord model representing products in the catalog (app/models/product.rb)
- **ProductExport_Model**: The ActiveRecord model representing exported product data (app/models/product_export.rb)

### Product Model Fields

- **name**: A string field storing the product's display name
- **sku**: A string field storing the Stock Keeping Unit, a unique identifier for the product
- **price**: A decimal field storing the product price in dollars with 2 decimal places
- **category**: A string field storing the product's category classification
- **active**: A boolean field indicating whether the product is currently active in the catalog

### ProductExport Model Fields

- **product_id**: An integer field storing the foreign key reference to the source Product record
- **name**: A string field storing the exported product name
- **sku**: A string field storing the exported product SKU
- **price_cents**: An integer field storing the product price converted to cents (price * 100)
- **category_slug**: A string field storing the URL-friendly version of the category name
- **exported_at**: A datetime field storing when the export occurred

### Query Scopes

- **active_scope**: A query scope that filters products where active equals true
- **inactive_scope**: A query scope that filters products where active equals false
- **by_category_scope**: A query scope that filters products by a specific category
- **recent_scope**: A query scope that orders products by creation date descending
- **price_range_scope**: A query scope that filters products within a specified price range

### Associations

- **product_association**: The belongs_to relationship from ProductExport to Product
- **product_exports_association**: The has_many relationship from Product to ProductExport

### Database Constraints

- **unique_constraint**: A database-level constraint ensuring no duplicate values in a column
- **null_constraint**: A database-level constraint preventing null values in a column
- **foreign_key_constraint**: A database-level constraint ensuring referential integrity between tables
