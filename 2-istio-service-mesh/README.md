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

In a separate terminal, view logs for the Istio sidecar of the Curity Identity Server:

```bash
POD=$(kubectl -n curity get pods --selector='role=curity-idsvr-runtime' -o=name)
kubectl -n curity logs -f "$POD" -c istio-proxy
```

Some debug output in an Envoy filter shows the client certificate that the client's sidecar sends.\
This workload identity enables the mTLS connection to succeed:

```text
-----BEGIN CERTIFICATE-----
MIIDRzCCAi+gAwIBAgIQcU3mqSN9xQ39IVQQX3kTFzANBgkqhkiG9w0BAQsFADAV
MRMwEQYDVQQKEwpjdXJpdHlkZW1vMB4XDTI1MTExNzExNTIwMloXDTI1MTExODEx
NTQwMlowADCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMMhQ8WhXVnw
dic12ahx8eSZHw9kA5pqwe7Nv8yZUQtnzL6/9xKpBvs/pXw9mxDxTWQaYSe/Xfw9
WbmhE+nQAg5XDS+6grworHzyuPs0g3iOci+0diYw8rGuKXK2iRaX3Hy2eIOWZFFf
AEyFrkPdF4kHNUQbM7peNtHA5b9W9WwdfUqjlmd/MGuoFHYZbaeAEvzpz3PadMaH
qnYBF0M2muOhffv3Dv86TyaIE2QDjF0kDzvPC0h0BunW48w7gqAs3Dxu2OgFN2w7
O6GH26IdV4Oz9HVGLxDyd98tAxWO7YGnjXpaX/A/M2/6Fa9kzjGSbltwB3I9ya4N
wddxqDWxCEcCAwEAAaOBpzCBpDAOBgNVHQ8BAf8EBAMCBaAwHQYDVR0lBBYwFAYI
KwYBBQUHAwEGCCsGAQUFBwMCMAwGA1UdEwEB/wQCMAAwHwYDVR0jBBgwFoAUSkN/
hI7yWKRXW0dJecRbYAgQhjEwRAYDVR0RAQH/BDowOIY2c3BpZmZlOi8vY3VyaXR5
ZGVtby9ucy9hcHBsaWNhdGlvbnMvc2Evd29ya2xvYWQtY2xpZW50MA0GCSqGSIb3
DQEBCwUAA4IBAQA0R4ePJDKadt7fxiO8cVyVJhR/It81HOExzA437ngoACYq0oyC
FoBlMoX2FJtHeYRZu4d8DO5ES5UOQ/DeLPjtcL/Q9bDrj7nLNfOvTD3G3HSXosIs
YNTuXCsHhodPiF9sqpFl6s3RmqFdPF/ZzLlyKtsLOFiWhsgckVipGErqdGude4tO
E2tTbw4O+MrH7KHk+rkc2QzT0ictYoQhx9HCKa7ojZeukd7R4XbNrxrMtZ6Xkttw
6zI5iu7sdoJL65bfaeQzhJRPuM7rwJkoL0zWhrikYE1vctC9UlmDx/TA+stYhtAc
gOI3mro3CAldMClaeAHM+YoGv/dDq2cDxBe+
-----END CERTIFICATE-----
```
