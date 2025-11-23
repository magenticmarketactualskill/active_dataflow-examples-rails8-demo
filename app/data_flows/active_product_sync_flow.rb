# frozen_string_literal: true
require 'active_data_flow'

# ProductSyncFlow demonstrates ActiveDataFlow functionality by syncing
# active products to an export table with data transformation.
#
# This DataFlow:
# - Reads from the products table (filtering active products)
# - Transforms price to cents and category to slug
# - Writes to the product_exports table
class ActiveProductSyncFlow
  include ActiveDataFlow::ActiveRecord2ActiveRecord

  source Product.where(active: true), batch_size: 100
  sink ProductExport, batch_size: 100
  runtime :heartbeat, interval: 3600

  def run
    Rails.logger.info("ActiveProductSyncFlow run")
    @flow.source.each do |product|
      Rails.logger.info("Processing product: #{product.id}")
      transformed = transform(product)
      Rails.logger.info("Transformed: #{transformed}")
      @flow.sink.write(transformed)
    end
  rescue StandardError => e
    Rails.logger.error("ProductSyncFlow error: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise
  end

  private

  # Transforms product data for export
  # Handles edge cases per Requirement 8:
  # - Null categories (8.2)
  # - Zero prices (8.3)
  def transform(product)
    {
      product_id: product.id,
      name: product.name,
      sku: product.sku,
      price_cents: (product.price.to_f * 100).to_i, # Handles zero prices (Req 8.3)
      category_slug: product.category&.parameterize || 'uncategorized', # Handles null categories (Req 8.2)
      exported_at: Time.current
    }
  end
end
