class AddRunAfterToActiveDataFlowDataFlowRuns < ActiveRecord::Migration[8.1]
  def change
    add_column :active_data_flow_data_flow_runs, :run_after, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    add_index :active_data_flow_data_flow_runs, :run_after
  end
end
