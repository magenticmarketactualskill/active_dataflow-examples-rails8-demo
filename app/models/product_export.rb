# frozen_string_literal: true

# ProductExport model represents transformed product data.
# This is the destination table for the ProductSyncFlow DataFlow.
class ProductExport < ApplicationRecord
  # Associations
  belongs_to :product

  # Validations
  validates :product_id, presence: true
  validates :name, presence: true
  validates :sku, presence: true
  validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :exported_at, presence: true

  # Scopes
  scope :recent_exports, -> { order(exported_at: :desc) }
  scope :exported_today, -> { where(exported_at: Time.current.beginning_of_day..Time.current.end_of_day) }
  scope :by_product, ->(product_id) { where(product_id: product_id) }

  # Class Methods

  # Calculates the sum of all price_cents values
  # @return [Integer] total value in cents
  def self.total_value
    sum(:price_cents)
  end

  # Returns a hash of category slugs with their export counts
  # @return [Hash] category slug => count
  def self.export_count_by_category
    group(:category_slug).count
  end
end
