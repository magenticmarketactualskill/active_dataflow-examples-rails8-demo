# frozen_string_literal: true

# Migration to add missing indexes required by the data models specification
# These indexes improve query performance for common filtering and sorting operations
class AddMissingIndexes < ActiveRecord::Migration[8.1]
  def change
    # Add index on active column for filtering active products (Requirement 10.4)
    add_index :products, :active unless index_exists?(:products, :active)
    
    # Add composite index on category and active for category-based filtering (Requirement 10.5)
    add_index :products, [:category, :active] unless index_exists?(:products, [:category, :active])
    
    # Add index on exported_at for time-based queries (Requirement 10.3)
    add_index :product_exports, :exported_at unless index_exists?(:product_exports, :exported_at)
    
    # Add foreign key constraint for referential integrity (Requirement 5.4)
    add_foreign_key :product_exports, :products unless foreign_key_exists?(:product_exports, :products)
  end
end
