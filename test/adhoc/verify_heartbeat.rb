# verify_heartbeat.rb
begin
  puts "Verifying Heartbeat Logic..."
  
  # Ensure flow exists and is active
  flow = ActiveDataFlow::DataFlow.find_by(name: 'product_sync_flow')
  unless flow
    ProductSyncFlow.register
    flow = ActiveDataFlow::DataFlow.find_by(name: 'product_sync_flow')
  end
  flow.update!(status: 'active')
  
  # Clear previous runs
  flow.data_flow_runs.destroy_all
  ProductExport.delete_all
  
  puts "Initial ProductExport count: #{ProductExport.count}"
  puts "Initial Pending Runs: #{flow.data_flow_runs.pending.count}"
  
  # Simulate Controller Logic
  puts "Simulating trigger_active_data_flows..."
  
  ActiveDataFlow::DataFlow.where(status: 'active').each do |data_flow|
    unless data_flow.data_flow_runs.pending.where(run_after: ..Time.current).exists?
      puts "Scheduling immediate run for #{data_flow.name}"
      data_flow.data_flow_runs.create!(
        run_after: Time.current,
        status: 'pending'
      )
    end
  end
  
  puts "Pending Runs before execution: #{flow.data_flow_runs.pending.count}"
  
  puts "Executing ScheduleFlowRuns..."
  ActiveDataFlow::Runtime::Heartbeat::ScheduleFlowRuns.create
  
  puts "Execution complete."
  puts "Final ProductExport count: #{ProductExport.count}"
  
  if ProductExport.count == 3
    puts "SUCCESS: Heartbeat triggered processing."
  else
    puts "FAILURE: Expected 3 exports, got #{ProductExport.count}"
  end

rescue => e
  puts "CRASHED: #{e.class}: #{e.message}"
  puts e.backtrace.take(5)
end
