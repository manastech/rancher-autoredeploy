require "json"
require "http/server"

module Rancher::Autoredeploy

  class HubWebhookHandler < HTTP::Handler

    def initialize(@redeployer : Redeployer)
    end

    def call(context)
      push_info = parse(context.request.body)
      spawn { @redeployer.pushed(*push_info.not_nil!) } if push_info
      context.response.print "OK\n"
      context.response.status_code = 200
    end

    def parse(body) : Tuple(String, String)?
      begin
        data = JSON.parse(body.not_nil!)
        repo_name = data["repository"]["repo_name"].as_s
        tag = data["push_data"]["tag"].as_s
        Rancher::Autoredeploy.logger.info("Received request for #{repo_name}:#{tag}")
        {repo_name, tag}
      rescue e
        Rancher::Autoredeploy.logger.error("Error parsing request body: #{e}. BODY=#{body.to_s}")
        nil
      end
    end

  end

end
