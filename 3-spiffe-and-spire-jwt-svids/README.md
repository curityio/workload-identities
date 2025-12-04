# Strong OAuth Client Credentials with SPIFFE

A deployment that uses SPIFFE JWT SVIDs as strong client credentials.\
A workload uses SPIFFE JWT SVIDs to get OAuth access tokens.

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

Then deploy the Curity Identity Server, supplying the path to a license file:

```bash
export LICENSE_FILE_PATH=license.json
./4-deploy-curity-identity-server.sh
```

Then deploy application workloads to enable inspection of SVID documents:

```bash
./5-deploy-application-workloads.sh
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

## Free Resources

Tear down the cluster when you have finished testing:

```bash
./6-delete-cluster.sh
```
