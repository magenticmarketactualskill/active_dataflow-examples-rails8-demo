#!/usr/bin/env ruby
# Double heartbeat test - verify redundant messages only on 2nd run
begin
  puts "="*60
  puts "FIRST RUN - Should see NEW_TRANSFORMED_RECORD messages"
  puts "="*60
  
  # Clear everything
  flow = ActiveDataFlow::DataFlow.find_by(name: 'product_sync_flow')
  unless flow
    ProductSyncFlow.register
    flow = ActiveDataFlow::DataFlow.find_by(name: 'product_sync_flow')
  end
  flow.update!(status: 'active')
  flow.data_flow_runs.destroy_all
  ProductExport.delete_all
  
  # First heartbeat
  ActiveDataFlow::DataFlow.where(status: 'active').each do |data_flow|
    unless data_flow.data_flow_runs.pending.where(run_after: ..Time.current).exists?
      data_flow.data_flow_runs.create!(
        run_after: Time.current,
        status: 'pending'
      )
    end
  end
  
  ActiveDataFlow::Runtime::Heartbeat::ScheduleFlowRuns.create
  
  first_count = ProductExport.count
  puts "First run completed: #{first_count} exports"
  
  puts "\n" + "="*60
  puts "SECOND RUN - Should see REDUNDENT_TRANSFORMED_RECORD messages"
  puts "="*60
  
  # Second heartbeat (products haven't changed)
  ActiveDataFlow::DataFlow.where(status: 'active').each do |data_flow|
    unless data_flow.data_flow_runs.pending.where(run_after: ..Time.current).exists?
      data_flow.data_flow_runs.create!(
        run_after: Time.current,
        status: 'pending'
      )
    end
  end
  
  ActiveDataFlow::Runtime::Heartbeat::ScheduleFlowRuns.create
  
  second_count = ProductExport.count
  puts "Second run completed: #{second_count} exports"
  
  puts "\n" + "="*60
  puts "RESULTS"
  puts "="*60
  
  if first_count == 3 && second_count == 3
    puts "✅ SUCCESS: Both runs completed correctly"
    puts "   - First run created 3 new exports"
    puts "   - Second run found 3 existing exports (no duplicates)"
    puts "   - Check logs above for REDUNDENT_TRANSFORMED_RECORD on 2nd run"
  else
    puts "❌ FAILURE: Unexpected export counts"
    puts "   - First run: #{first_count} (expected 3)"
    puts "   - Second run: #{second_count} (expected 3)"
  end

rescue => e
  puts "❌ CRASHED: #{e.class}: #{e.message}"
  puts e.backtrace.take(5)
end
