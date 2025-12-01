class AddNextSourceIdToDataFlows < ActiveRecord::Migration[8.1]
  def change
    add_column :active_data_flow_data_flows, :next_source_id, :integer
    add_index :active_data_flow_data_flows, :next_source_id
  end
end
