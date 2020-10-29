# gitops-fluxv2

Demo of bootstrapping a generic cluster with the gitops toolkit.

## Usage

A convenience script is provided to get up and running quickly.  The script will deploy to your current `kubeconfigs` context, and requires `kustomize` and `kubectl` to be installed and available on your `$PATH`.

```bash
bootstrap/init.sh
```

The script will:

0. Install the gotk components
1. Deploy the `GitRepository` pointing to this repository
2. Deploy the umbrella `Kustomization` for the `admin` and `steve` tenant

From there, gotk will begin reconciling all deployments in the `cluster/admin/<tenant>` kustomization path:

* gotk (self managing)
* istio
* cert-manager (for creating certificates for the defined gateway)
* gate-keeper
* observability stack (loki, prometheus, grafana)

As an optional deployment, rancher is also provided but disabled.

## Umbrella Kustomization

The bootstrapping process is kicked off by a top level tenant `Kustomization`, which points to a kustomization path containing a series of `HelmReleases` and additional k8s resources. 

Helm is an alternative for the umbrella, but due to limitations in `helm install` not supporting exhaustive retry's, it's currently not possible to define custom resources that have not yet been registered alongside resources that create those resources.  The most common use case being declaring a `CR` alongside the `HelmRelease` that creates the appropriate `CRD`.  Rather than build out the appropriate dependency chain, we simply apply the top level `Kustomization` and let gotk perform the eventual reconciliation for us.

## Kustomize Layout

The `admin` tenant is structure in such a way to clearly identify the tools being installed, while still remaining extensible for different deployment environments.

This repository contains two example environments: `dev`, and the inadequately named `prod`, both of which inherit their base configurations from `../base`.

Several overlay models are used:

* generic kustomize overlays: since the umbrella `Kustomization` is still just a kustomization path, the typical kustomize overlays can be leveraged
* `env-config`: leveraging `HelmReleases` in gotk provides a great deal of helm configuration with [value overrides](https://toolkit.fluxcd.io/components/helm/helmreleases/#values-overrides), which can be defined via a kustomize `configMapGenerator` or `secretGenerator`

