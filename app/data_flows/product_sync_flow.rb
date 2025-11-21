# frozen_string_literal: true
require 'active_data_flow'

# ProductSyncFlow demonstrates ActiveDataFlow functionality by syncing
# active products to an export table with data transformation.
#
# This DataFlow:
# - Reads from the products table (filtering active products)
# - Transforms price to cents and category to slug
# - Writes to the product_exports table
class ProductSyncFlow
  def initialize
    @source = ActiveDataFlow::Connector::Source::ActiveRecordSource.new(
      scope: Product.active,
      scope_params: [],
      batch_size: 3
    )

    @sink = ActiveDataFlow::Connector::Sink::ActiveRecordSink.new(
        model_class: ProductExport
    )
  end

  def run
    @source.each do |message|
      transformed = transform(message.data)
      @sink.write(transformed)
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
  def transform(data)
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
