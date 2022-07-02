# My Kubernetes Cluster

Provides a quick terraform manifest for provisioning a Kubernetes cluster.

## Installation

`bin/install.sh` provides the commands necessary to provision all the cluster resources.

## What's Included?

- An EKS Kubernetes cluster
- An implementation of Cert Manager and Cert Issuer from jetpack.io
- ingress-nginx

## Deleting

```bash
terraform destroy
```

@todo: You still have to go delete the load balancer created by `ingress-nginx` manually.