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

{
  kustomize build cluster/admin/base/gotk/toolkit | kubectl apply -f -
  kubectl wait --for=condition=available --timeout=60s --all deployments -n gotk-system
  kustomize build cluster/admin/base/gotk/chart-repositories | kubectl apply -f -

  kubectl apply -f bootstrap/repos
  kubectl apply -f bootstrap/tenants
}