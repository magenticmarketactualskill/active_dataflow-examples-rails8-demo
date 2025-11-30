# frozen_string_literal: true

# Product model represents items in the product catalog.
# This is the source table for the ProductSyncFlow DataFlow.
class Product < ApplicationRecord
  # Associations
  has_many :product_exports, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :sku, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :active_sorted, -> { where(active: true).order(:id) }
  scope :inactive, -> { where(active: false) }
  scope :by_category, ->(category) { where(category: category) }
  scope :recent, -> { order(created_at: :desc) }
  scope :price_range, ->(min, max) { where(price: min..max) }

  # Instance Methods

  # Returns the price converted to cents as an integer
  # @return [Integer] price in cents
  def price_in_cents
    (price * 100).to_i
  end

  # Returns a URL-friendly version of the category
  # @return [String, nil] parameterized category or 'uncategorized' if nil
  def category_slug
    category&.parameterize || 'uncategorized'
  end

  # Returns a formatted string combining name and SKU
  # @return [String] display name with SKU
  def display_name
    "#{name} (#{sku})"
  end

  # Returns whether the product is active
  # @return [Boolean] true if active, false otherwise
  def active?
    active == true
  end
end
