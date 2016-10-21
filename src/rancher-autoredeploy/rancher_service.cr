module Rancher::Autoredeploy

  class RancherLaunchConfig
    JSON.mapping({
      image_uuid: { type: String, key: "imageUuid", nilable: true },
      kind: String?,
      labels: Hash(String, String)
    })
  end

  class RancherService
    JSON.mapping({
      id: String,
      kind: String?,
      type: String,
      name: String,
      state: String,
      accountId: String,
      launch_config: { type: RancherLaunchConfig, key: "launchConfig" }
    })

    delegate labels, image_uuid, to: launch_config
  end

end
