# frozen_string_literal: true

module ActiveDataFlow
  module Runtime
    module Heartbeat
      class DataFlowsController < ActionController::Base
        skip_before_action :verify_authenticity_token
        before_action :authenticate_heartbeat!
        before_action :check_ip_whitelist!
        
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
