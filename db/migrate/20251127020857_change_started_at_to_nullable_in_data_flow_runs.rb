class ChangeStartedAtToNullableInDataFlowRuns < ActiveRecord::Migration[8.1]
  def change
    change_column_null :active_data_flow_data_flow_runs, :started_at, true
  end
end
