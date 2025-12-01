module ActiveDataFlow 
    class DataFlowsController < ApplicationController
        def index
            @data_flows = ActiveDataFlow::DataFlow.all
            Rails.logger.info "[DataFlowsController#index] Loaded #{@data_flows.count} data flows"
        end
        
        def show
            @data_flow = ActiveDataFlow::DataFlow.find(params[:id])
        end
        
        def toggle_status
            @data_flow = ActiveDataFlow::DataFlow.find(params[:id])
            new_status = @data_flow.status == 'active' ? 'inactive' : 'active'
            @data_flow.update(status: new_status)
            redirect_to active_data_flow_data_flows_path, notice: "Data flow #{new_status}"
        end
    end
end
