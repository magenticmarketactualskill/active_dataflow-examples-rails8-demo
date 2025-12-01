#!/usr/bin/env ruby
# verify_cursor_advancement.rb - Test cursor-based incremental processing
begin
  puts "=" * 70
  puts "Testing Cursor-Based Data Flow Processing"
  puts "=" * 70
  
  # Setup: Ensure flow exists and is active
  flow = ActiveDataFlow::DataFlow.find_by(name: 'product_sync_flow')
  unless flow
    ProductSyncFlow.register
    flow = ActiveDataFlow::DataFlow.find_by(name: 'product_sync_flow')
  end
  flow.update!(status: 'active', next_source_id: nil) # Reset cursor
  
  # Clear previous runs and exports
  flow.data_flow_runs.destroy_all
  ProductExport.delete_all
  
  puts "\nInitial State:"
  puts "  Products in DB: #{Product.active.count}"
  puts "  Exports: #{ProductExport.count}"
  puts "  Cursor: #{flow.next_source_id.inspect}"
  
  # ===== FIRST RUN ===== 
  puts "\n" + "=" * 70
  puts "FIRST RUN - Should process products 1-3"
  puts "=" * 70
  
  ActiveDataFlow::DataFlow.where(status: 'active').each do |data_flow|
    unless data_flow.data_flow_runs.pending.where(run_after: ..Time.current).exists?
      data_flow.data_flow_runs.create!(
        run_after: Time.current,
        status: 'pending'
      )
    end
  end
  
  ActiveDataFlow::Runtime::Heartbeat::ScheduleFlowRuns.create
  flow.reload
  
  first_exports = ProductExport.pluck(:product_id).sort
  first_cursor = flow.next_source_id
  
  puts "\nAfter First Run:"
  puts "  Exported product IDs: #{first_exports.inspect}"
  puts "  Export count: #{ProductExport.count}"
  puts "  Cursor position: #{first_cursor}"
  puts "  Expected: [1, 2, 3], cursor=3"
  
  # ===== SECOND RUN =====
  puts "\n" + "=" * 70
  puts "SECOND RUN - Should process products 4-6"
  puts "=" * 70
  
  ActiveDataFlow::DataFlow.where(status: 'active').each do |data_flow|
    unless data_flow.data_flow_runs.pending.where(run_after: ..Time.current).exists?
      data_flow.data_flow_runs.create!(
        run_after: Time.current,
        status: 'pending'
      )
    end
  end
  
  ActiveDataFlow::Runtime::Heartbeat::ScheduleFlowRuns.create
  flow.reload
  
  second_exports = ProductExport.pluck(:product_id).sort
  second_cursor = flow.next_source_id
  
  puts "\nAfter Second Run:"
  puts "  Exported product IDs: #{second_exports.inspect}"
  puts "  Export count: #{ProductExport.count}"
  puts "  Cursor position: #{second_cursor}"
  puts "  Expected: [1, 2, 3, 4, 5, 6], cursor=6"
  
  # ===== VERIFICATION =====
  puts "\n" + "=" * 70
  puts "VERIFICATION RESULTS"
  puts "=" * 70
  
  success = true
  
  # Check first run
  if first_exports == [1, 2, 3]
    puts "✅ First run: Correctly exported products 1-3"
  else
    puts "❌ First run: Expected [1, 2, 3], got #{first_exports.inspect}"
    success = false
  end
  
  if first_cursor == 3
    puts "✅ First cursor: Advanced to 3"
  else
    puts "❌ First cursor: Expected 3, got #{first_cursor}"
    success = false
  end
  
  # Check second run
  if second_exports == [1, 2, 3, 4, 5, 6]
    puts "✅ Second run: Correctly exported products 1-6 (cumulative)"
  else
    puts "❌ Second run: Expected [1, 2, 3, 4, 5, 6], got #{second_exports.inspect}"
    success = false
  end
  
  if second_cursor == 6
    puts "✅ Second cursor: Advanced to 6"
  else
    puts "❌ Second cursor: Expected 6, got #{second_cursor}"
    success = false
  end
  
  # Check for duplicates
  if second_exports.length == second_exports.uniq.length
    puts "✅ No duplicate exports created"
  else
    puts "❌ Duplicate exports found!"
    success = false
  end
  
  puts "\n" + "=" * 70
  if success
    puts "🎉 SUCCESS: Cursor-based processing working correctly!"
    puts "   - Each run processes new records only"
    puts "   - Cursor advances with each batch"
    puts "   - No duplicates created"
  else
    puts "💥 FAILURE: Issues detected in cursor-based processing"
  end
  puts "=" * 70

rescue => e
  puts "\n❌ CRASHED: #{e.class}: #{e.message}"
  puts e.backtrace.take(10)
end
