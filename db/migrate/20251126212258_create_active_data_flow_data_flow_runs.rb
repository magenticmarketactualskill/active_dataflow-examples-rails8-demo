# frozen_string_literal: true

class CreateActiveDataFlowDataFlowRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :active_data_flow_data_flow_runs do |t|
      t.references :data_flow, null: false, foreign_key: { to_table: :active_data_flow_data_flows }
      t.string :status, null: false
      t.datetime :started_at, null: false
      t.datetime :ended_at
      t.text :error_message
      t.text :error_backtrace

      t.timestamps
    end

    add_index :active_data_flow_data_flow_runs, [:data_flow_id, :created_at], name: 'index_data_flow_runs_on_data_flow_id_and_created_at'
    add_index :active_data_flow_data_flow_runs, :status
  end
end
