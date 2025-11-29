# frozen_string_literal: true
module ActiveDataFlow 
# DataFlowsController handles manual triggering of DataFlow execution
# and displays DataFlow information
class DataFlowRunsController < ApplicationController
  attr_accessor :product_count, :export_count, :last_export

  # GET /active_data_flow/data_flows/:data_flow_id/data_flow_runs
  def index
    @data_flow = ActiveDataFlow::DataFlow.find(params[:data_flow_id])
    @data_flow_runs = @data_flow.data_flow_runs.order(created_at: :desc)
  end

  # GET /data_flow
  # Shows ProductSyncFlow details and status
  def show
    @data_flow_run = ActiveDataFlow::DataFlowRun.find(params[:id])
    @data_flow = @data_flow_run.data_flow
  end
  
  # POST /active_data_flow/data_flows/:data_flow_id/data_flow_runs
  def create
    @data_flow = ActiveDataFlow::DataFlow.find(params[:data_flow_id])
    @data_flow.heartbeat_event
    redirect_to main_app.active_data_flow_data_flow_data_flow_runs_path(@data_flow), notice: "Data flow run triggered"
  end
  
  # DELETE /active_data_flow/data_flows/:data_flow_id/data_flow_runs/purge
  def purge
    @data_flow = ActiveDataFlow::DataFlow.find(params[:data_flow_id])
    @data_flow.data_flow_runs.destroy_all
    redirect_to main_app.active_data_flow_data_flow_data_flow_runs_path(@data_flow), notice: "All runs purged"
  end

  # GET /data_flow
  # Triggers DataFlow execution via UI
  def heartbeat_click
    Rails.logger.info "[DataFlowRunsController.heartbeat_click] called"
    trigger_active_data_flows
    redirect_to main_app.root_path, notice: "DataFlow heartbeat triggered"
  end

  # GET /data_flow_event
  # Triggers DataFlow execution via cron/automated process
  def heartbeat_event
    Rails.logger.info "[DataFlowRunsController.heartbeat_event] called"
    trigger_active_data_flows
    head :ok
  end

  private

  def trigger_active_data_flows
    ActiveDataFlow::DataFlow.where(status: 'active').each do |data_flow|
      data_flow.schedule_next_run
    end
  end
end
end