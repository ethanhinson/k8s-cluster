# Cert Issuer

Provides the `jetstack/cert-manager` chart.

## Solvers

See the configuration here: https://cert-manager.io/docs/configuration/.

## Setup

Because cert-manager doesn't install CRDs out of the box. Prior to installing this chart you must first execute:

```bash
helm install \                       
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.6.1 \
  --set installCRDs=true
```

Then you can proceed with: `helm install cert-issuer .  -f values.yaml`