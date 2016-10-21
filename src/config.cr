module Rancher::Autoredeploy

  macro env_config(name)
    def self.{{ name }} : String
      ENV["{{ name }}".upcase]
    end
  end

  macro env_config(name, default)
    def self.{{ name }} : String
      ENV["{{ name }}".upcase]? || {{ default }}
    end
  end

  macro env_config?(name)
    def self.{{ name }} : String?
      ENV["{{ name }}".upcase]?
    end
  end

  macro env_config_int(name)
    def self.{{ name }} : Int32
      ENV["{{ name }}".upcase].to_i32
    end
  end

  macro env_config_int(name, default)
    def self.{{ name }} : Int32
      ENV["{{ name }}".upcase].to_i32 rescue {{ default }}
    end
  end

  env_config     log_severity, "INFO"
  env_config     bind_address, "0.0.0.0"
  env_config_int bind_port, 8080
  env_config     rancher_host
  env_config     rancher_project_id
  env_config     rancher_api_key
  env_config     rancher_api_secret
  env_config     rancher_autoredeploy_label_name, "tech.manas.service.autoredeploy"
  env_config     rancher_autoredeploy_default, "true"
  env_config     docker_hub_key

  module Config
    def config
      Rancher::Autoredeploy
    end
  end

end
