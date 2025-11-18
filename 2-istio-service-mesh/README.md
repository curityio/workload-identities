# Internal Mutual TLS for OAuth Requests

A deployment of the Curity Identity Server to an Istio service mesh.\
The mesh updates internal OAuth requests to use mutual TLS and ensure data confidentiality.

## Deploy the System

First, create a local cluster:

```bash
./1-create-cluster.sh
```

Then, deploy a default deployment of the Istio service mesh:

```bash
./2-deploy-service-mesh.sh
```

Then, deploy the Curity Identity Server, supplying the path to a license file:

```bash
export LICENSE_FILE_PATH=license.json
./3-deploy-curity-identity-server.sh
```

Then, deploy application workloads:

```bash
./4-deploy-application-workloads.sh
```

## Test Mutual TLS Connections

Remote to the workload client's pod:

```bash
POD=$(kubectl -n applications get pods --selector='app=workload-client' -o=name)
kubectl -n applications exec -it "$POD" -- bash
```

Then call endpoints of the Curity Identity Server.\
The client calls a plain HTTP URL, which sidecars upgrade to an internal mTLS connection:

```bash
curl -s http://curity-idsvr-runtime-svc.curity:8443/oauth/v2/oauth-anonymous/jwks | jq
```

## View X509 Workload Identities

In a separate terminal, get a shell in the Istio sidecar of the client workload:

```bash
SIDECAR=$(kubectl -n applications get pods --selector='app=workload-client' -o=name)
kubectl -n applications exec -it "$SIDECAR" -c istio-proxy -- bash
```

Then run the following commands to view the X509 workload identity for OAuth endpoints:

```bash
openssl s_client -showcerts \
    -connect curity-idsvr-runtime-svc.curity:8443 \
    -CAfile /var/run/secrets/istio/root-cert.pem 2>/dev/null | \
    openssl x509 -in /dev/stdin -text -noout
```

The certificate's X509 URI SAN provides a SPIFFE ID that identifies runtime workloads:

```text
X509v3 Subject Alternative Name: critical
    URI:spiffe://curitydemo/ns/curity/sa/curity-idsvr-runtime
```
