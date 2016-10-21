require "http/server"

module Rancher::Autoredeploy

  class HubWebhookAuthHandler < HTTP::Handler

    KEY_PARAM_NAME = "key"

    def initialize(@key : String)
    end

    def call(context)
      unless context.request.query_params.has_key?(KEY_PARAM_NAME)
        Rancher::Autoredeploy.logger.warn("Received request without #{KEY_PARAM_NAME} query parameter")
        context.response.status_code = 401
        return
      end

      unless context.request.query_params[KEY_PARAM_NAME] == @key
        Rancher::Autoredeploy.logger.warn("Received request with invalid key #{KEY_PARAM_NAME} '#{context.request.query_params[KEY_PARAM_NAME]}'")
        context.response.status_code = 403
        return
      end

      unless context.request.headers["Content-Type"]? == "application/json"
        Rancher::Autoredeploy.logger.warn("Received request with invalid content type '#{context.request.headers["Content-Type"]?}'")
        context.response.status_code = 501
        return
      end

      call_next(context)
    end

  end

end
