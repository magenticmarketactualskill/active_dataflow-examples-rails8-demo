# frozen_string_literal: true

module ActiveDataFlow
  class DataFlowsController < ApplicationController
    layout 'application'
    before_action :set_data_flow, only: [:show, :edit, :update, :destroy, :toggle_status]

    def index
      @data_flows = ActiveDataFlow::DataFlow.all.order(:name)
    end

    def show
    end

    def new
      @data_flow = DataFlow.new
    end

    def edit
    end

    def create
      @data_flow = ActiveDataFlow::DataFlow.new(data_flow_params)
      
      if @data_flow.save
        redirect_to active_data_flow_data_flow_path(@data_flow), notice: 'Data flow was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @data_flow.update(data_flow_params)
        redirect_to active_data_flow_data_flow_path(@data_flow), notice: 'Data flow was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @data_flow.destroy
      redirect_to active_data_flow_data_flows_path, notice: 'Data flow was successfully deleted.'
    end

    def toggle_status
      new_status = @data_flow.status == 'active' ? 'inactive' : 'active'
      @data_flow.update(status: new_status)
      redirect_to active_data_flow_data_flows_path, notice: "Data flow #{new_status}."
    end

    private

    def set_data_flow
      @data_flow = ActiveDataFlow::DataFlow.find(params[:id])
    end

    def data_flow_params
      params.require(:data_flow).permit(:name, :status, :source, :sink, :runtime)
    end
  end
end
