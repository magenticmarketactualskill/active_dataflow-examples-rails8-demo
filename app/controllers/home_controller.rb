# frozen_string_literal: true

# HomeController displays the main dashboard with application statistics
class HomeController < ApplicationController
  # GET /
  # Displays product and export statistics
  # Requirement 2: View product catalog through web interface
  def index
    
    @product_count = Product.count
    @active_product_count = Product.active.count # Using scope from Requirement 3.1
    @inactive_product_count = Product.inactive.count # Using scope from Requirement 3.2
    @export_count = ProductExport.count
    @last_export = ProductExport.recent_exports.first # Using scope from Requirement 7.1
  end

  # DELETE /reset
  # Purges all product exports and data flow runs, and resets cursors
  def reset
    ProductExport.destroy_all
    ActiveDataFlow::DataFlowRun.destroy_all
    
    # Reset cursors on all data flows so they start from the beginning
    ActiveDataFlow::DataFlow.update_all(next_source_id: nil)
    
    redirect_to root_path, notice: "Demo reset complete. All exports, runs, and cursors have been reset."
  end
end
