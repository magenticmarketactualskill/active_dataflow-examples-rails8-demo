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

  # Customize message ID extraction
  def get_message_id(message)
    Rails.logger.info "[DataFlowProductSyncFlow.get_message_id] called"
    message['id']
  end

  # Customize trasformed ID extraction
  def get_transformed_id(transformed)
    Rails.logger.info "[DataFlowProductSyncFlow.get_transformed_id] called"
    transformed['id']
  end

  def has_changes(previously_transformed, transformed)
      # Check if the data has actually changed
      transformed.name != previously_transformed[:name] ||
      transformed.sku != previously_transformed[:sku] ||
      transformed.price_cents != previously_transformed[:price_cents] ||
      transformed.category_slug != previously_transformed[:category_slug]
  end

  def find_previous_transformed(transformed_id:)
    ProductExport.find_by(product_id: transformed_id)
  end
  
  def if_changed(previously_transformed, transformed)
    {
        product_id: transformed[:product_id],
        existing_export_id: previously_transformed.id,
        changes: {
          name: [previously_transformed.name, transformed[:name]],
          sku: [previously_transformed.sku, transformed[:sku]],
          price_cents: [previously_transformed.price_cents, transformed[:price_cents]],
          category_slug: [previously_transformed.category_slug, transformed[:category_slug]]
        }.select { |_k, v| v[0] != v[1] }
    }
  end

  # Detects if the transformed data would collide with an existing export
  # Returns collision details if found, nil otherwise
  def transform_collision(transformed:)
    previously_transformed = find_previous_transformed(transformed_id:  get_transformed_id(transformed))
    if previously_transformed
      has_changes = has_changes(previously_transformed, transformed)
      if has_changes
        Rails.logger.info "[DataFlowProductSyncFlow.transform_collision] detected changes: #{if_changed(previously_transformed, transformed)}"
      else
        Rails.logger.info "[DataFlowProductSyncFlow.transform_collision] detected no changes in: #{transformed}"
      end 
    else
      Rails.logger.info "[DataFlowProductSyncFlow.transform_collision] stored new record: #{transformed}"
    end
  end
end
