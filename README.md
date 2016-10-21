# Rancher Autoredeploy

This [Crystal](http://crystal-lang.org/) program brings [Docker Cloud's autoredeploy](https://docs.docker.com/docker-cloud/apps/auto-redeploy/) feature to Rancher. It listens for requests from Docker Hub in a specified port, and upgrades all services that depend on the container.

## Usage

Coming soon!

## How it works

Coming soon!

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
