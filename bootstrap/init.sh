#!/bin/bash

set -e

# info logs the given argument at info log level.
info() {
    echo "[INFO] " "$@"
}

# warn logs the given argument at warn log level.
warn() {
    echo "[WARN] " "$@" >&2
}

# fatal logs the given argument at fatal log level.
fatal() {
    echo "[ERROR] " "$@" >&2
    exit 1
}

need() {
  command -v "$1" >/dev/null 2>&1 || fatal "'$1' required on \$PATH but not found"
}

deploy_gotk() {
  info "Installing gotk components"
  # Apply gotk components
  kustomize build cluster/admin/base/gotk/toolkit | kubectl apply -f -

  info "Waiting for gotk components to initialize"
  kubectl wait --for=condition=available --timeout=60s --all deployments -n gotk-system

  info "Registering required HelmRepositories"
  # apply helmrepositories
  kustomize build cluster/admin/base/gotk/chart-repositories | kubectl apply -f -
}

deploy_umbrella() {
  info "Applying the current GitRepository"

  # apply the repository with the current branch
  cat bootstrap/repos/* | sed -e 's/$BRANCH/'$(git rev-parse --abbrev-ref HEAD)'/g' | kubectl apply -f -

  info "Applying the umbrella tenants"

  # apply the tenants
  kubectl apply -f bootstrap/tenants
}

{
  deploy_gotk
  deploy_umbrella
}