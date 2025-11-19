# Strong OAuth Client Credentials with SPIFFE

A deployment that uses SPIFFE JWT SVIDs and X509 SVIDs as strong client credentials.\
A workload uses SPIFFE SVIDs to get OAuth access tokens.

## Deploy the System

First, create a local cluster:

```bash
./1-create-cluster.sh
```

Deploy a cert-manager root CA as an upstream authority for SPIRE:

```bash
./2-deploy-cert-manager.sh
```

Then deploy SPIRE:

```bash
./3-deploy-spire.sh
```

The example deployment then integrates a service mesh with SPIRE:

```bash
./4-deploy-service-mesh.sh
```

Then deploy application workloads to enable inspection of SVID documents:

```bash
./5-deploy-application-workloads.sh
```

Then deploy the Curity Identity Server, supplying the path to a license file.\
Start with the simpler deployment that only uses JWT SVIDs:

```bash
export LICENSE_FILE_PATH=license.json
export CONFIGURE_X509_TRUST=false
./6-deploy-curity-identity-server.sh
```

## Use the Admin UI

To view security settings in the Curity Identity Server, use port-forwarding to expose the Admin UI:

```bash
POD=$(kubectl -n curity get pods --selector='role=curity-idsvr-admin' -o=name)
kubectl -n curity port-forward "$POD" 6749:6749
```

Then browse to `http://localhost:6749/admin` and sign in as user `admin` with password `Password1`.

## Test JWT SVIDs

Remote to the workload client's pod:

```bash
POD=$(kubectl -n applications get pods --selector='app=workload-client' -o=name)
kubectl -n applications exec -it "$POD" -- bash
```

Then run a flow to get an access token using a SPIFFE JWT SVID:

```bash
./jwt-svid-authenticate-and-get-access-token.sh
```

The script outputs the header and payload of the SPIRE JWT SVID:

```json
{
  "alg": "ES256",
  "kid": "rwn03JoPg7NkRhMxqiWu32OjbvXMwjc9",
  "typ": "JWT"
}
{
  "aud": [
    "https://login.curitydemo.example/oauth/v2/oauth-token"
  ],
  "exp": 1763544838,
  "iat": 1763541238,
  "iss": "https://oidc-discovery.curitydemo",
  "sub": "spiffe://curitydemo/ns/applications/sa/workload-client"
}
```

The script then outputs the header and payload of the access token that the workload uses to call APIs:

```json
{
  "kid": "-1327236000",
  "x5t": "7vcSVKpOYe3ckTlcYLLm5Y_Vdpg",
  "alg": "ES256"
}
{
  "jti": "284fbf2f-0875-4db8-8bf3-48ecfce78847",
  "delegationId": "790369fb-1e5d-4261-95bf-3415890d46b3",
  "exp": 1763377508,
  "nbf": 1763376608,
  "scope": "reports",
  "iss": "https://login.curitydemo.example/oauth/v2/oauth-anonymous",
  "sub": "jwt_assertion_client",
  "aud": "api.curitydemo.example",
  "iat": 1763376608,
  "purpose": "access_token"
}
```

## Test X509 SVIDs

Redeploy the Curity Identity Server with a more complex deployment that also uses X509 SVIDs:

```bash
export LICENSE_FILE_PATH=license.json
export CONFIGURE_X509_TRUST=true
./6-deploy-curity-identity-server.sh
```

Remote to the workload client's pod:

```bash
POD=$(kubectl -n applications get pods --selector='app=workload-client' -o=name)
kubectl -n applications exec -it "$POD" -- bash
```

Then run a flow to get an access token using a SPIFFE X509 SVID:

```bash
./x509-svid-authenticate-and-get-access-token.sh
```

The script outputs its X509 SVID client certificate.\
The client identifies itself from the SPIFFE ID in the certificate's URL SAN:

```text
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            ad:1b:1a:d6:f6:56:84:aa:7d:41:2c:0b:db:f9:73:da
        Signature Algorithm: ecdsa-with-SHA256
        Issuer: C = SE, O = curitydemo, CN = curitydemo-intermediate-ca, serialNumber = 14942068239048109091663378999972525619
        Validity
            Not Before: Nov 19 09:47:52 2025 GMT
            Not After : Nov 19 13:48:02 2025 GMT
        X509v3 extensions:
            X509v3 Subject Alternative Name: 
                URI:spiffe://curitydemo/ns/applications/sa/workload-client
```

The script then outputs the header and payload of the access token that the workload uses to call APIs.\
This is a sender-constrained access token, as indicated by its `cnf` claim:

```json
{
  "kid": "-1327236000",
  "x5t": "7vcSVKpOYe3ckTlcYLLm5Y_Vdpg",
  "alg": "ES256"
}
{
  "jti": "f94fe033-3ae1-4b0f-93d2-94ec61e25786",
  "delegationId": "21366062-3e2f-4edc-abdc-4ea69a796d7e",
  "exp": 1763547300,
  "nbf": 1763546400,
  "scope": "reports",
  "iss": "https://login.curitydemo.example/oauth/v2/oauth-anonymous",
  "sub": "x509_certificate_client",
  "aud": "api.curitydemo.example",
  "iat": 1763546400,
  "purpose": "access_token",
  "cnf": {
    "x5t#S256": "KzsDJ3mnKKBnpbu0YkpYzH_O4YYCNHc-d_KNLwLVe5E"
  }
}
```

## Free Resources

Tear down the cluster when you have finished testing:

```bash
./7-delete-cluster.sh
```
