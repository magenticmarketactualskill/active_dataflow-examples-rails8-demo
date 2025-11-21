# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data
ProductExport.destroy_all
Product.destroy_all

puts "Creating sample products..."

# Create sample products with varied data
products_data = [
  { name: "Wireless Mouse", sku: "TECH-001", price: 29.99, category: "Electronics", active: true },
  { name: "USB-C Cable", sku: "TECH-002", price: 12.50, category: "Electronics", active: true },
  { name: "Laptop Stand", sku: "TECH-003", price: 45.00, category: "Electronics", active: true },
  { name: "Mechanical Keyboard", sku: "TECH-004", price: 89.99, category: "Electronics", active: false },
  { name: "Coffee Mug", sku: "HOME-001", price: 15.99, category: "Home & Kitchen", active: true },
  { name: "Desk Lamp", sku: "HOME-002", price: 34.50, category: "Home & Kitchen", active: true },
  { name: "Notebook Set", sku: "OFFICE-001", price: 18.75, category: "Office Supplies", active: true },
  { name: "Pen Pack", sku: "OFFICE-002", price: 8.99, category: "Office Supplies", active: false },
  { name: "Monitor Stand", sku: "TECH-005", price: 55.00, category: "Electronics", active: true },
  { name: "Webcam HD", sku: "TECH-006", price: 79.99, category: "Electronics", active: true },
  { name: "Desk Organizer", sku: "OFFICE-003", price: 22.50, category: "Office Supplies", active: true },
  { name: "Water Bottle", sku: "HOME-003", price: 19.99, category: "Home & Kitchen", active: false },
  { name: "Phone Holder", sku: "TECH-007", price: 14.99, category: "Electronics", active: true },
  { name: "Headphone Stand", sku: "TECH-008", price: 25.00, category: "Electronics", active: true },
  { name: "Cable Management", sku: "OFFICE-004", price: 16.50, category: "Office Supplies", active: true }
]

products_data.each do |data|
  Product.create!(data)
end

puts "Created #{Product.count} products (#{Product.where(active: true).count} active, #{Product.where(active: false).count} inactive)"

# Create DataFlow configuration
# TODO: Uncomment when ActiveDataFlow gems are fully implemented
# puts "Creating DataFlow configuration..."
# 
# ActiveDataFlow::RailsHeartbeatApp::DataFlow.find_or_create_by!(name: "Product Sync Flow") do |df|
#   df.enabled = true
#   df.run_interval = 60  # Run every 60 seconds
#   df.configuration = {
#     class_name: "ProductSyncFlow"
#   }
# end
# 
# puts "DataFlow configuration created!"

puts "\nSetup complete! You can now:"
puts "1. Start the server: rails server"
puts "2. Visit http://localhost:3000 to see products"
puts "3. TODO: Trigger DataFlow when ActiveDataFlow gems are implemented"
puts "4. View exports: http://localhost:3000/product_exports"
