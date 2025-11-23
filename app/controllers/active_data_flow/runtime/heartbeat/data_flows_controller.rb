# frozen_string_literal: true

module ActiveDataFlow
  module Runtime
    module Heartbeat
      class DataFlowsController < ActionController::Base
        skip_before_action :verify_authenticity_token
        before_action :authenticate_heartbeat!
        before_action :check_ip_whitelist!

        def heartbeat
          Rails.logger.info "[Heartbeat] Starting heartbeat check at #{Time.current}"
          
          flows = DataFlow.due_to_run.lock("FOR UPDATE SKIP LOCKED")
          Rails.logger.info "[Heartbeat] Found #{flows.count} flow(s) due to run"
          
          triggered_count = 0

          flows.each do |flow|
            Rails.logger.info "[Heartbeat] Executing flow: #{flow.name}"
            FlowExecutor.execute(flow)
            triggered_count += 1
            Rails.logger.info "[Heartbeat] Successfully executed flow: #{flow.name}"
          rescue => e
            Rails.logger.error "[Heartbeat] Flow execution failed for #{flow.name}: #{e.message}"
            Rails.logger.error e.backtrace.first(5).join("\n")
            # Continue with next flow
          end

          Rails.logger.info "[Heartbeat] Completed: #{triggered_count}/#{flows.count} flows executed"
          
          render json: {
            flows_due: flows.count,
            flows_triggered: triggered_count,
            timestamp: Time.current
          }
        rescue => e
          Rails.logger.error "[Heartbeat] Heartbeat failed: #{e.message}"
          Rails.logger.error e.backtrace.first(10).join("\n")
          render json: { error: e.message }, status: :internal_server_error
        end

        private

        def authenticate_heartbeat!
          return unless ActiveDataFlow::Runtime::Heartbeat.config.authentication_enabled

          token = request.headers["X-Heartbeat-Token"]
          expected = ActiveDataFlow::Runtime::Heartbeat.config.authentication_token

          unless ActiveSupport::SecurityUtils.secure_compare(token.to_s, expected.to_s)
            log_authentication_failure
            render json: { error: "Unauthorized" }, status: :unauthorized
          end
        end

        def check_ip_whitelist!
          return unless ActiveDataFlow::Runtime::Heartbeat.config.ip_whitelisting_enabled

          whitelist = ActiveDataFlow::Runtime::Heartbeat.config.whitelisted_ips
          source_ip = request.remote_ip

          unless whitelist.include?(source_ip)
            log_ip_rejection(source_ip)
            render json: { error: "Forbidden" }, status: :forbidden
          end
        end

        def log_authentication_failure
          Rails.logger.warn(
            "Heartbeat authentication failed from #{request.remote_ip} at #{Time.current}"
          )
        end

        def log_ip_rejection(ip)
          Rails.logger.warn(
            "Heartbeat IP whitelist rejection: #{ip} at #{Time.current}"
          )
        end
      end
    end
  end
end
