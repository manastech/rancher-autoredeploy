require "./logger"
require "./config"
require "./rancher-autoredeploy/*"

module Rancher::Autoredeploy

  def self.main
    config = Rancher::Autoredeploy
    api = RancherAPI.new(config.rancher_host, config.rancher_project_id, config.rancher_api_key, config.rancher_api_secret)
    redeployer = Redeployer.new(api, config.rancher_autoredeploy_label_name, config.rancher_autoredeploy_default)

    server = HTTP::Server.new(config.bind_address, config.bind_port, [
      HubWebhookAuthHandler.new(config.docker_hub_key),
      HubWebhookHandler.new(redeployer)
    ])

    Rancher::Autoredeploy.logger.info("Listening for docker hub webhooks in #{config.bind_address}:#{config.bind_port}")
    at_exit { server.close }
    server.listen
  end

end

Rancher::Autoredeploy.main
