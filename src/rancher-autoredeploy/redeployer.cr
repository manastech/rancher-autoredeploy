module Rancher::Autoredeploy

  class Redeployer

    include Rancher::Autoredeploy::Logger

    def initialize(@api : RancherAPI, @autoredeploy_label_name : String, @autoredeploy_default : String)
    end

    def pushed(repo_name : String, tag : String)
      candidates = services.select do |service|
        service.image_uuid == "docker:#{repo_name}:#{tag}" || \
        (tag == "latest" && service.image_uuid == "docker:#{repo_name}")
      end

      logger.info("Found no services using image #{repo_name}:#{tag}") if candidates.empty?
      candidates.each do |service|
        if service.labels.fetch(@autoredeploy_label_name, @autoredeploy_default) == "true"
          logger.info("Upgrading service #{service.name} (#{service.id}) to latest version of #{repo_name}:#{tag}")
          upgrade(service)
        elsif service.labels.has_key?(@autoredeploy_label_name)
          logger.info("Skipping service #{service.name} (#{service.id}) since label #{@autoredeploy_label_name} is set to #{service.labels.fetch(@autoredeploy_label_name)}")
        else
          logger.info("Skipping service #{service.name} (#{service.id}) since label #{@autoredeploy_label_name} is unset and RANCHER_AUTOREDEPLOY_DEFAULT is set to #{@autoredeploy_default}")
        end
      end
    end

    def services
      # TODO: Cache services list
      @api.list_services
    end

    def upgrade(service)
      spawn do
        # Start the upgrade
        response = @api.upgrade(service.id)
        unless response.state == "upgrading"
          logger.error("Unexpected status #{response.state} after upgrade request, skipping service upgrade")
          next
        end
        logger.debug("Started upgrade for service #{service.name} (#{service.id})")

        # Poll the service status until it is upgraded, then finish the upgrade
        attempts = 0
        while attempts < 60
          sleep 5
          state = try_get_service_state(service)
          if state == "upgraded"
            logger.debug("Finishing upgrade of #{service.name} (#{service.id})")
            @api.finish_upgrade(service.id)
            break
          elsif state
            logger.debug("Service #{service.name} (#{service.id}) is in state #{state}, waiting to finish upgrade")
          end
        end
      end
    end

    private def try_get_service_state(service)
      begin
        @api.get_service(service.id).state
      rescue
        logger.warn("Error querying state for service #{service.name} (#{service.id})")
        nil
      end
    end

  end

end
