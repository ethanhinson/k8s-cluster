# Charts

Charts I usually use when provisioning clusters. Included are `ingress-nginx` and `cert-issuer` via Let's Encrypt. I like
to use IaC to define the actual infrastructure and then use Helm once the cluster has been provisioned. This is because
I believe that the audiences or departments for when those assets change is ideally two different groups of people:

- NOC for infrastructure changes
- Product teams for provisioning assets in the cluster once it is running.