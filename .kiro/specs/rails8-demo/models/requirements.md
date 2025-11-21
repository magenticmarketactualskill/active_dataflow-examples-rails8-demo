# Requirements Document - Data Models

## Introduction

This document specifies the requirements for the data models in the Rails 8 demo application. The models represent the core data structures for the product catalog synchronization use case, including source products and their exported transformations. These models serve as the foundation for demonstrating ActiveDataFlow's data processing capabilities.

For term definitions, see #[[file:../glossary.md]]

## Requirements

### Requirement 1

**User Story:** As a developer, I want a Product model that stores catalog information, so that the application has source data for DataFlow processing

#### Acceptance Criteria

1. THE Product_Model SHALL have a name field that stores product names as strings with a maximum length of 255 characters
2. THE Product_Model SHALL have a sku field that stores unique product identifiers as strings
3. THE Product_Model SHALL have a price field that stores product prices as decimal numbers with precision 10 and scale 2
4. THE Product_Model SHALL have a category field that stores product categories as strings
5. THE Product_Model SHALL have an active field that stores boolean values with a default value of true
6. THE Product_Model SHALL have created_at and updated_at timestamp fields managed automatically by Rails
7. THE Product_Model SHALL enforce that name, sku, and price fields cannot be null
8. THE Product_Model SHALL enforce a unique constraint on the sku field

### Requirement 2

**User Story:** As a developer, I want the Product model to validate data integrity, so that invalid product data cannot be saved to the database

#### Acceptance Criteria

1. WHEN a product is saved without a name, THE Product_Model SHALL reject the save operation with a validation error
2. WHEN a product is saved without a sku, THE Product_Model SHALL reject the save operation with a validation error
3. WHEN a product is saved without a price, THE Product_Model SHALL reject the save operation with a validation error
4. WHEN a product is saved with a duplicate sku, THE Product_Model SHALL reject the save operation with a uniqueness validation error
5. WHEN a product is saved with a negative price, THE Product_Model SHALL reject the save operation with a numericality validation error
6. WHEN a product is saved with a price of zero, THE Product_Model SHALL accept the save operation
7. WHEN a product is saved without a category, THE Product_Model SHALL accept the save operation allowing null categories

### Requirement 3

**User Story:** As a developer, I want the Product model to provide query scopes, so that I can easily filter products for DataFlow processing

#### Acceptance Criteria

1. WHEN the active scope is called, THE Product_Model SHALL return only products where active equals true
2. WHEN the inactive scope is called, THE Product_Model SHALL return only products where active equals false
3. WHEN the by_category scope is called with a category name, THE Product_Model SHALL return products matching that category
4. WHEN the recent scope is called, THE Product_Model SHALL return products ordered by created_at in descending order
5. WHEN the price_range scope is called with min and max values, THE Product_Model SHALL return products with prices within that range

### Requirement 4

**User Story:** As a developer, I want a ProductExport model that stores transformed product data, so that the application can track exported products

#### Acceptance Criteria

1. THE ProductExport_Model SHALL have a product_id field that stores integer references to Product records
2. THE ProductExport_Model SHALL have a name field that stores product names as strings
3. THE ProductExport_Model SHALL have a sku field that stores product SKUs as strings
4. THE ProductExport_Model SHALL have a price_cents field that stores prices as integers representing cents
5. THE ProductExport_Model SHALL have a category_slug field that stores URL-friendly category names as strings
6. THE ProductExport_Model SHALL have an exported_at field that stores datetime values indicating when the export occurred
7. THE ProductExport_Model SHALL have created_at and updated_at timestamp fields managed automatically by Rails
8. THE ProductExport_Model SHALL enforce that product_id, name, sku, price_cents, and exported_at fields cannot be null

### Requirement 5

**User Story:** As a developer, I want the ProductExport model to define relationships, so that I can navigate between products and their exports

#### Acceptance Criteria

1. WHEN the product association is accessed on a ProductExport instance, THE ProductExport_Model SHALL return the associated Product record
2. WHEN the product_exports association is accessed on a Product instance, THE Product_Model SHALL return all associated ProductExport records
3. WHEN a Product is destroyed, THE Rails_App SHALL handle the associated ProductExport records according to the defined dependency strategy
4. THE ProductExport_Model SHALL validate that the product_id references an existing Product record
5. WHEN querying ProductExport records, THE Rails_App SHALL support eager loading of associated Product records to prevent N+1 queries

### Requirement 6

**User Story:** As a developer, I want the ProductExport model to validate data integrity, so that invalid export data cannot be saved

#### Acceptance Criteria

1. WHEN a product export is saved without a product_id, THE ProductExport_Model SHALL reject the save operation with a validation error
2. WHEN a product export is saved without a name, THE ProductExport_Model SHALL reject the save operation with a validation error
3. WHEN a product export is saved without a sku, THE ProductExport_Model SHALL reject the save operation with a validation error
4. WHEN a product export is saved without a price_cents, THE ProductExport_Model SHALL reject the save operation with a validation error
5. WHEN a product export is saved with a negative price_cents, THE ProductExport_Model SHALL reject the save operation with a numericality validation error
6. WHEN a product export is saved without an exported_at timestamp, THE ProductExport_Model SHALL reject the save operation with a validation error

### Requirement 7

**User Story:** As a developer, I want the ProductExport model to provide query methods, so that I can analyze export history

#### Acceptance Criteria

1. WHEN the recent_exports scope is called, THE ProductExport_Model SHALL return exports ordered by exported_at in descending order
2. WHEN the exported_today scope is called, THE ProductExport_Model SHALL return exports where exported_at is within the current day
3. WHEN the by_product scope is called with a product_id, THE ProductExport_Model SHALL return all exports for that product
4. WHEN the total_value method is called, THE ProductExport_Model SHALL calculate the sum of all price_cents values
5. WHEN the export_count_by_category method is called, THE ProductExport_Model SHALL return a hash of category slugs with their export counts

### Requirement 8

**User Story:** As a developer, I want the Product model to provide helper methods, so that I can easily access computed values

#### Acceptance Criteria

1. WHEN the price_in_cents method is called on a Product instance, THE Product_Model SHALL return the price converted to cents as an integer
2. WHEN the category_slug method is called on a Product instance, THE Product_Model SHALL return a URL-friendly version of the category
3. WHEN the display_name method is called on a Product instance, THE Product_Model SHALL return a formatted string combining name and sku
4. WHEN the active? method is called on a Product instance, THE Product_Model SHALL return true if active equals true, false otherwise
5. WHEN the category is null and category_slug is called, THE Product_Model SHALL return a default slug value or nil

### Requirement 9

**User Story:** As a developer, I want the models to support bulk operations efficiently, so that DataFlow processing performs well with large datasets

#### Acceptance Criteria

1. WHEN bulk inserting ProductExport records, THE ProductExport_Model SHALL use Rails insert_all for efficient batch insertion
2. WHEN bulk updating Product records, THE Product_Model SHALL use Rails update_all for efficient batch updates
3. WHEN deleting multiple ProductExport records, THE ProductExport_Model SHALL use Rails delete_all for efficient batch deletion
4. THE Product_Model SHALL support find_each for memory-efficient iteration over large result sets
5. THE ProductExport_Model SHALL support find_in_batches for processing exports in configurable batch sizes

### Requirement 10

**User Story:** As a developer, I want the models to include appropriate database indexes, so that queries perform efficiently

#### Acceptance Criteria

1. THE Product_Model SHALL have a unique index on the sku column
2. THE ProductExport_Model SHALL have an index on the product_id column
3. THE ProductExport_Model SHALL have an index on the exported_at column for time-based queries
4. THE Product_Model SHALL have an index on the active column for filtering active products
5. THE Product_Model SHALL have a composite index on category and active columns for category-based filtering of active products
