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
end
