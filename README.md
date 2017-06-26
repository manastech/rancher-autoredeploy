# Rancher Autoredeploy

[![CircleCI](https://circleci.com/gh/manastech/rancher-autoredeploy/tree/master.svg?style=svg)](https://circleci.com/gh/manastech/rancher-autoredeploy/tree/master)

**Deprecated in favour of [Docker Hub Webhooks](http://rancher.com/docs/rancher/v1.6/en/cattle/webhook-service/#upgrading-a-service-based-on-docker-hub-webhooks) in Rancher 1.6**

This [Crystal](http://crystal-lang.org/) program brings [Docker Cloud's autoredeploy](https://docs.docker.com/docker-cloud/apps/auto-redeploy/) feature to Rancher. It listens for requests from Docker Hub in a specified port, and upgrades all services that depend on the container.

## How it works

Rancher autoredeploy listens for HTTP requests from Docker Hub Webhooks on a configurable address and port, secured using a random secret. Whenever there is a notification of a new image being pushed, it scans all services in the Rancher environment and fires an upgrade for all of those that match the published image and tag.

This behaviour can be fine-tuned by setting `RANCHER_AUTOREDEPLOY_DEFAULT` to `false`, in which case only the services with the label `tech.manas.service.autoredeploy` set to `true` will be upgraded.

## Usage

The easiest way to run Rancher Autoredeploy on your Rancher server is through its [docker image](https://hub.docker.com/r/manastech/rancher-autoredeploy/). Run a new stack using the `manastech/rancher-autoredeploy` image, and configure it with the required credentials.

```yaml
redeployer:
  image: manastech/rancher-autoredeploy:latest
  environment:
    BIND_PORT: 8090
    BIND_ADDRESS: "0.0.0.0"
    RANCHER_HOST: your.rancher.server
    RANCHER_PROJECT_ID: yourprojectid
    RANCHER_API_KEY: yourapikey
    RANCHER_API_SECRET: yourapisecret
    DOCKER_HUB_KEY: randomsecret
  ports:
    - "8090:8090"
```

This will start an instance of the redeployer image, listening on port 8090 for requests from docker hub including the `randomsecret` key, and updating the services in project `yourprojectid` at `your.rancher.server`. Note that the bind port and address can be configured to the values that best match your setup.

The next step is to add a webhook to your docker hub repositories, so they will notify the `redeployer` container when there is a new version of an image. On the webhooks tab of your project, simply add an entry to `http://your.rancher.node:8090/autoredeploy?key=randomsecret`.

**Important:** remember to set `io.rancher.container.pull_image` label on your service to `always`, to ensure that the new image is actually pulled when upgrading. Future versions of this project may set this label automatically.

## Configuration

Accepts the following environment variables for configuration:

* `LOG_SEVERITY`, "INFO"
* `BIND_ADDRESS`, "0.0.0.0", address to bind for listening Docker Hub webhooks
* `BIND_PORT`, 8080, port to bind for listening Docker Hub webhooks
* `RANCHER_HOST`, host to your rancher server
* `RANCHER_PROJECT_ID`, ID (not name) of the environment to manage
* `RANCHER_API_KEY`, API key for the environment
* `RANCHER_API_SECRET`, API secret for the environment
* `RANCHER_AUTOREDEPLOY_DEFAULT`, "true", whether services with the updated image will be upgraded by default
* `RANCHER_AUTOREDEPLOY_LABEL_NAME`, "tech.manas.service.autoredeploy", Rancher service label to set to either true or false to signal whther this service should be upgraded
* `DOCKER_HUB_KEY`, secret key that the Docker Hub webhook should provide as a query parameter named `key`, for security purposes

## Contributing

You know the drill ;-)

## Contributors

- [spalladino](https://github.com/spalladino) Santiago Palladino - creator, maintainer
