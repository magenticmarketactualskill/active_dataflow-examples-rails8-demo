# frozen_string_literal: true
require 'active_data_flow'

# ProductSyncFlow demonstrates ActiveDataFlow functionality by syncing
# active products to an export table with data transformation.
#
# This DataFlow:
# - Reads from the products table (filtering active products)
# - Transforms price to cents and category to slug
# - Writes to the product_exports table
class ProductSyncFlow < ActiveDataFlow::DataFlow

  # Added
  attr_accessor :product_count, :export_count, :last_export
  
  def refresh
    @product_count = Product.active.count
    @export_count = ProductExport.count
    @last_export = ProductExport.order(exported_at: :desc).first
  end

  # Generated
  def self.register
    source = ActiveDataFlow::Connector::Source::ActiveRecordSource.new(
      scope: Product.active_sorted,
      scope_name: :active,
      scope_params: [],
      batch_size: 3
    )

    sink = ActiveDataFlow::Connector::Sink::ActiveRecordSink.new(
        model_class: ProductExport
    )
    
    runtime = ActiveDataFlow::Runtime::Heartbeat::Base.new(
    )

    find_or_create(
      name: "product_sync_flow",
      source: source,
      sink: sink,
      runtime: runtime
    )
  end

  private

  # Transforms product data for export
  # Handles edge cases per Requirement 8:
  # - Null categories (8.2)
  # - Zero prices (8.3)
  def transform(data)
    Rails.logger.info "[DataFlowProductSyncFlow.transform] called"
    {
      product_id: data['id'],
      name: data['name'],
      sku: data['sku'],
      price_cents: (data['price'].to_f * 100).to_i, # Handles zero prices (Req 8.3)
      category_slug: data['category']&.parameterize || 'uncategorized', # Handles null categories (Req 8.2)
      exported_at: Time.current
    }
  end
end
