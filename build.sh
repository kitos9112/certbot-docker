#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
trap 1 2 3 6

# This script builds certbot docker and all certbot dns plugin docker against the latest release of Certbot inside 32-bit ARMv7 architectures
# Usage: ./build.sh

if [[ $(uname -m) != 'armv7l' ]]; then echo "This script only runs within ARMv7 32-bit systems"; exit 1; fi

BuildAndPushCore() { 
    # Fetch Certbot version on 1st positional argument
    CERTBOT_VERSION="$1"
    # Fetch Docker repo name on 2nd positional argument
    DOCKER_REPO="$2" 
    # Build certbot core Docker image
    docker build \
        --build-arg CERTBOT_VERSION="${CERTBOT_VERSION}" \
        -f source/core-armv7l/Dockerfile \
        -t "${DOCKER_REPO}:v${CERTBOT_VERSION}" \
        .
    docker push "${DOCKER_REPO}:v${CERTBOT_VERSION}"
    docker tag "${DOCKER_REPO}:v${CERTBOT_VERSION}" "${DOCKER_REPO}:latest"
    docker push "${DOCKER_REPO}:latest"
}

BuildAndPushPluginDNS() {
    # Fetch Certbot version on 1st positional argument
    CERTBOT_VERSION="$1"
    # Fetch Certbot version on 2nd positional argument
    PLUGIN="$2" #"dns-cloudflare"
    # Fetch Docker repo name on 3rd positional argument
    DOCKER_REPO="$3" 
    # Build certbot core Docker image
    docker build \
        --build-arg CERTBOT_VERSION="${CERTBOT_VERSION}" \
        --build-arg DOCKER_REPO="${DOCKER_REPO}" \
        --build-arg PLUGIN_NAME="${PLUGIN}" \
        -f source/plugin-armv7l/Dockerfile \
        -t "${DOCKER_REPO}-${PLUGIN}:v${CERTBOT_VERSION}" \
        .
    docker push "${DOCKER_REPO}-${PLUGIN}:v${CERTBOT_VERSION}"
    docker tag  "${DOCKER_REPO}-${PLUGIN}:v${CERTBOT_VERSION}" "${DOCKER_REPO}-${PLUGIN}:latest"
    docker push "${DOCKER_REPO}-${PLUGIN}:latest"
}

CleanUp() {
    DOCKER_REPO="$1" 
    docker rmi $(docker images --filter=reference="${DOCKER_REPO}*")
}

if [[ -z $CERTBOT_VERSION ]]; then CERTBOT_VERSION=$(curl -s https://api.github.com/repos/certbot/certbot/releases/latest | grep -oP '"tag_name": "v\K(.*)(?=")'); fi
if [[ -z $DOCKER_REPO ]]; then DOCKER_REPO="kitos9112/certbot-armv7l"; fi

# Step 1: Certbot core Docker
BuildAndPushCore "${CERTBOT_VERSION}" "${DOCKER_REPO}"

# Step 2: Certbot dns plugins Docker

CERTBOT_PLUGINS=(
    "dns-dnsmadeeasy"
    "dns-dnsimple"
    "dns-ovh"
    "dns-cloudflare"
    "dns-cloudxns"
    "dns-digitalocean"
    "dns-google"
    "dns-luadns"
    "dns-nsone"
    "dns-rfc2136"
    "dns-route53"
    "dns-gehirn"
    "dns-linode"
    "dns-sakuracloud"
)

for CERTBOT_PLUGIN in "${CERTBOT_PLUGINS[@]}"; do
    BuildAndPushPluginDNS "${CERTBOT_VERSION}" "${CERTBOT_PLUGIN}" "${DOCKER_REPO}"
done

# Step 3: Clean up all built images
CleanUp "$DOCKER_REPO"



