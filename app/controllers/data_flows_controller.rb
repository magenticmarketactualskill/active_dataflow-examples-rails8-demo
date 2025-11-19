# frozen_string_literal: true

# DataFlowsController handles manual triggering of DataFlow execution
# and displays DataFlow information
class DataFlowsController < ApplicationController
  # GET /data_flow
  # Shows ProductSyncFlow details and status
  def show
    @product_count = Product.active.count
    @export_count = ProductExport.count
    @last_export = ProductExport.order(exported_at: :desc).first
  end

  # POST /heartbeat
  # GET /heartbeat
  # Triggers the ProductSyncFlow execution manually
  # Requirement 5: Manual DataFlow execution via HTTP
  def heartbeat
    begin
      # Execute the ProductSyncFlow
      flow = ProductSyncFlow.new
      flow.run
      
      @status = "success"
      @message = "ProductSyncFlow executed successfully!"
      @export_count = ProductExport.count
      
      respond_to do |format|
        format.html { redirect_to product_exports_path, notice: @message }
        format.json { render json: { status: @status, message: @message, export_count: @export_count }, status: :ok }
      end
    rescue StandardError => e
      # Log the error with full details (Requirement 8.5)
      Rails.logger.error("ProductSyncFlow execution failed: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      
      @status = "error"
      @message = "Error executing DataFlow: #{e.message}"
      
      respond_to do |format|
        format.html { redirect_to root_path, alert: @message }
        format.json { render json: { status: @status, message: @message, error: e.message }, status: :internal_server_error }
      end
    end
  end
end
