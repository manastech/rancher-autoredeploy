require "./rancher_service"
require "http/client"

module Rancher::Autoredeploy

  class RancherAPI

    class RancherServicesResponse
      JSON.mapping({
        data: Array(RancherService)
      })
    end

    class RancherAPIError
      JSON.mapping({
        id: String,
        type: String,
        status: Int32,
        code: String,
        message: String?,
        detail: String?
      })

      def error_details
        [code, message, detail].compact.join(", ")
      end
    end

    def initialize(@host : String, @project_id : String, @api_key : String, @api_secret : String)
    end

    def list_services
      raw_response = http_client.get("/v1/projects/#{@project_id}/services")
      check_response!(raw_response, "listing services")
      RancherServicesResponse.from_json(raw_response.body).data
    end

    def get_service(service_id : String)
      raw_response = http_client.get("/v1/projects/#{@project_id}/services/#{service_id}")
      check_response!(raw_response, "getting service #{service_id}")
      RancherService.from_json(raw_response.body)
    end

    def upgrade(service_id : String)
      empty_strategies = %q({ "inServiceStrategy": {"secondaryLaunchConfigs": [ ]}, "toServiceStrategy": { } })
      raw_response = http_client.post("/v1/projects/#{@project_id}/services/#{service_id}/?action=upgrade", nil, empty_strategies)
      check_response!(raw_response, "upgrading service #{service_id}")
      RancherService.from_json(raw_response.body)
    end

    def finish_upgrade(service_id : String)
      raw_response = http_client.post("/v1/projects/#{@project_id}/services/#{service_id}/?action=finishupgrade", nil, "{ }")
      check_response!(raw_response, "finishing upgrade for service #{service_id}")
      RancherService.from_json(raw_response.body)
    end

    private def http_client
      client = HTTP::Client.new(@host)
      client.basic_auth(@api_key, @api_secret)
      client.before_request do |req|
        req.headers["Accept"] = "application/json"
        req.headers["Content-Type"] = "application/json"
      end
      client
    end

    private def check_response!(response, msg)
      unless response.success?
        error_details = begin
          RancherAPIError.from_json(response.body).error_details
        rescue
          "Unknown error"
        end
        Rancher::Autoredeploy.logger.error("Error in request to Rancher API #{msg}: #{error_details}")
        raise "Error in Rancher API #{msg}"
      end
    end

  end

end
