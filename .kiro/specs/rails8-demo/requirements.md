# Requirements Document

## Introduction

This document specifies the requirements for a Rails 8 demonstration application that showcases ActiveDataFlow functionality. The application implements a product catalog synchronization use case where products from a source table are filtered, transformed, and exported to a destination table. The demo serves as a reference implementation for integrating ActiveDataFlow into Rails applications.

For term definitions, see #[[file:glossary.md]]

## Requirements

### Requirement 1

**User Story:** As a developer, I want to set up the Rails 8 demo application, so that I can explore ActiveDataFlow functionality in a working environment

#### Acceptance Criteria

1. WHEN the developer runs bundle install, THE Rails_App SHALL install all required dependencies
2. WHEN the developer runs database setup commands, THE Rails_App SHALL create the Product_Catalog and Product_Export_Table
3. WHEN the developer runs database seed commands, THE Rails_App SHALL populate the Product_Catalog with 15 sample products including 12 Active_Products and 3 inactive products
4. WHEN the developer starts the Rails server, THE Rails_App SHALL serve the Web_Interface on port 3000
5. WHEN the Rails_App starts successfully, THE Web_Interface SHALL be accessible at http://localhost:3000

### Requirement 2

**User Story:** As a user, I want to view the product catalog through a web interface, so that I can see what products are available in the system

#### Acceptance Criteria

1. WHEN the user navigates to the root URL, THE Web_Interface SHALL display a list of all products from the Product_Catalog
2. THE Web_Interface SHALL display products ordered by creation date in descending order
3. WHEN the user views a product in the list, THE Web_Interface SHALL show the product name, SKU, price, category, and active status
4. WHEN the user clicks on a product, THE Web_Interface SHALL display detailed information for that specific product
5. THE Web_Interface SHALL render product information without errors when the Product_Catalog contains zero products

### Requirement 3

**User Story:** As a user, I want to view exported products through a web interface, so that I can verify which products have been synchronized

#### Acceptance Criteria

1. WHEN the user navigates to the product exports URL, THE Web_Interface SHALL display all records from the Product_Export_Table
2. WHEN the user views an export record, THE Web_Interface SHALL show the product name, SKU, Price_Cents, Category_Slug, and exported timestamp
3. THE Web_Interface SHALL display the exported_at timestamp in a human-readable format
4. THE Web_Interface SHALL render the exports page without errors when the Product_Export_Table contains zero records

### Requirement 4

**User Story:** As a system integrator, I want the DataFlow to filter and transform product data, so that only relevant products are exported in the correct format

#### Acceptance Criteria

1. WHEN the Product_Sync_Flow executes, THE DataFlow SHALL read only Active_Products from the Product_Catalog
2. WHEN the Product_Sync_Flow processes a product, THE DataFlow SHALL convert the price field to Price_Cents
3. WHEN the Product_Sync_Flow processes a product, THE DataFlow SHALL generate a Category_Slug from the category field using parameterization
4. WHEN the Product_Sync_Flow writes to the Product_Export_Table, THE DataFlow SHALL include the product_id, name, SKU, Price_Cents, Category_Slug, and current timestamp as exported_at
5. WHEN the Product_Sync_Flow encounters an inactive product, THE DataFlow SHALL exclude that product from the export

### Requirement 5

**User Story:** As a system administrator, I want to trigger the DataFlow execution via HTTP, so that I can manually initiate product synchronization

#### Acceptance Criteria

1. WHEN a POST request is sent to the Heartbeat_Endpoint, THE Rails_App SHALL trigger the Product_Sync_Flow execution
2. WHEN the Heartbeat_Endpoint receives a valid request, THE Rails_App SHALL return an HTTP 200 status code
3. WHEN the Product_Sync_Flow completes successfully, THE Rails_App SHALL update the Product_Export_Table with new records
4. THE Heartbeat_Endpoint SHALL be accessible at /active_data_flow/runtime/heartbeat/data_flows/heartbeat
5. WHEN the Heartbeat_Endpoint is triggered, THE Rails_App SHALL process the request within 30 seconds for datasets up to 1000 products

### Requirement 6

**User Story:** As a developer, I want clear documentation and error messages, so that I can troubleshoot issues and understand the application structure

#### Acceptance Criteria

1. THE Rails_App SHALL include a README file that documents setup instructions, application structure, and usage
2. WHEN a database error occurs, THE Rails_App SHALL display a meaningful error message to the user
3. WHEN a required dependency is missing, THE Rails_App SHALL fail with a clear error message indicating which dependency is needed
4. THE Rails_App SHALL include inline code comments explaining the purpose of the Product_Sync_Flow transformations
5. WHEN the server port is already in use, THE Rails_App SHALL provide guidance on using an alternative port

### Requirement 7

**User Story:** As a developer, I want the application to follow Rails conventions, so that the codebase is maintainable and familiar

#### Acceptance Criteria

1. THE Rails_App SHALL organize models in the app/models directory
2. THE Rails_App SHALL organize controllers in the app/controllers directory
3. THE Rails_App SHALL organize DataFlow definitions in the app/data_flows directory
4. THE Rails_App SHALL define routes in the config/routes.rb file following RESTful conventions
5. THE Rails_App SHALL use Rails migrations for all database schema changes
6. THE Rails_App SHALL follow Rails naming conventions for models, controllers, and views

### Requirement 8

**User Story:** As a quality assurance engineer, I want the application to handle edge cases gracefully, so that the system remains stable under various conditions

#### Acceptance Criteria

1. WHEN the Product_Catalog is empty, THE Rails_App SHALL display an empty product list without errors
2. WHEN a product has a null category, THE Product_Sync_Flow SHALL generate a Category_Slug with a default value or skip the slug generation
3. WHEN a product has a price of zero, THE Product_Sync_Flow SHALL convert it to zero Price_Cents
4. WHEN the Product_Export_Table already contains a record for a product, THE Product_Sync_Flow SHALL handle duplicate prevention or updates according to the defined strategy
5. WHEN the database connection fails, THE Rails_App SHALL return an HTTP 500 error with appropriate logging
