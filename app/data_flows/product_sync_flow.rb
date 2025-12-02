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

  class Source < ActiveDataFlow::Connector::Source::ActiveRecordSource
    def initialize(scope: nil, scope_params: [])
      # Use provided values or defaults
      scope ||= Product.active_sorted
      
      super(
        scope: scope,
        scope_params: scope_params
      )
    end
    
    protected
    
    # Override to provide the correct scope name for serialization
    def derive_scope_name
      'active_sorted'
    end
  end

  class Runtime < ActiveDataFlow::Runtime::Base
    def initialize(batch_size: 3, interval: 10, **options)
      super(batch_size: batch_size, interval: interval, **options)
    end
    
    # Transforms product data for export
    # Handles edge cases per Requirement 8:
    # - Null categories (8.2)
    # - Zero prices (8.3)
    def transform(data)
      Rails.logger.info "[ProductSyncFlow.Runtime.transform] called"
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

  class SinkCollision < ActiveDataFlow::Connector::Sink::Collision

    def predicted_write_result(transformed:)
      result = nil
      # Detects if the transformed data would collide with an existing export
      # Returns collision details if found, nil otherwise
      if previously_transformed = find_previous_transformed(transformed: transformed)
        if change_detected(previously_transformed, transformed)
          Rails.logger.info "[ProductSyncFlow.SinkCollision] detected changes: #{change_desc(previously_transformed, transformed)}"
          result = UPDATED_TRANSFORMED_RECORD
        else
          result = REDUNDENT_TRANSFORMED_RECORD
          Rails.logger.info "[ProductSyncFlow.SinkCollision] detected no changes in: #{transformed}"
        end 
      else
        Rails.logger.info "[ProductSyncFlow.SinkCollision] stored new record: #{transformed}"
        result = NEW_TRANSFORMED_RECORD
      end
      result
    end
    
    private
    
    def change_desc(previously_transformed, transformed)
      {
          product_id: transformed[:product_id],
          existing_transformed_id: previously_transformed.id,
          changes: {
            name: [previously_transformed.name, transformed[:name]],
            sku: [previously_transformed.sku, transformed[:sku]],
            price_cents: [previously_transformed.price_cents, transformed[:price_cents]],
            category_slug: [previously_transformed.category_slug, transformed[:category_slug]]
          }.select { |_k, v| v[0] != v[1] }
      }
    end

    # Customize message ID extraction
    def get_message_id(message)
      Rails.logger.info "[ProductSyncFlow.get_message_id] called"
      message['id']
    end

    # Customize transformed ID extraction
    def get_transformed_id(transformed)
      Rails.logger.info "[ProductSyncFlow.get_transformed_id] called"
      transformed[:product_id]
    end

    def change_detected(previously_transformed, transformed)
        # Check if the data has actually changed
        name_change = previously_transformed.name != transformed[:name]
        sku_change = previously_transformed.sku != transformed[:sku]
        cents_change = previously_transformed.price_cents != transformed[:price_cents]
        category_slug_change = previously_transformed.category_slug != transformed[:category_slug]

        name_change || sku_change || cents_change || category_slug_change
    end

    def find_previous_transformed(transformed:)
      ProductExport.find_by(product_id:  get_transformed_id(transformed))
    end

  end
  
  class Sink < ActiveDataFlow::Connector::Sink::Base

    def initialize(model_class: nil, sink_collision_class: nil, **options)
      # Use provided values or defaults
      model_class ||= ProductExport
      sink_collision_class ||= SinkCollision
      
      super(
        model_class: model_class,
        sink_collision_class: sink_collision_class,
        **options
      )
    end
  end
  
  # Added
  attr_accessor :product_count, :export_count, :last_export
  
  def refresh
    @product_count = Product.active.count
    @export_count = ProductExport.count
    @last_export = ProductExport.order(exported_at: :desc).first
  end

  # Generated
  def self.register
    find_or_create(
      name: "product_sync_flow",
      source: Source.new,
      sink: Sink.new,
      runtime: Runtime.new
    )
  end

end
