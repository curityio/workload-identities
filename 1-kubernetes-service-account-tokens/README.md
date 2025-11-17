# Strong OAuth Client Credentials in Kubernetes

A deployment that uses Kubernetes built-in strong credential capabilities.\
A workload uses Kubernetes service account tokens to get OAuth access tokens.

## Deploy the System

First, create a local cluster:

```bash
./1-create-cluster.sh
```

Then, deploy the Curity Identity Server, supplying the path to a license file:

```bash
export LICENSE_FILE_PATH=license.json
./2-deploy-curity-identity-server.sh
```

Then, deploy application workloads:

```bash
./3-deploy-application-workloads.sh
```

## Use the Admin UI

To view security settings in the Curity Identity Server, use port-forwarding to expose the Admin UI:

```bash
POD=$(kubectl -n curity get pods --selector='role=curity-idsvr-admin' -o=name)
kubectl -n curity port-forward "$POD" 6749:6749
```

Then browse to `http://localhost:6749/admin` and sign in as user `admin` with password `Password1`.

## Test Workload Identities

Remote to the workload client's pod:

```bash
POD=$(kubectl -n applications get pods --selector='app=workload-client' -o=name)
kubectl -n applications exec -it "$POD" -- bash
```

Then run a flow to get an access token using a Kubernetes service account token:

```bash
./authenticate-and-get-access-token.sh
```

The script outputs the header and payload of the service account token used for authentication:

```json
{
  "alg": "RS256",
  "kid": "amfKVpyk2xBM9LZ3cIshwsmgNTvbpJS4l_Z_SxCur_8"
}
{
  "aud": [
    "https://login.curitydemo.example/oauth/v2/oauth-token"
  ],
  "exp": 1763380172,
  "iat": 1763376572,
  "iss": "https://kubernetes.default.svc.cluster.local",
  "jti": "cf0845fa-e075-41af-9b0b-2a3b94fb331c",
  "kubernetes.io": {
    "namespace": "applications",
    "node": {
      "name": "curitydemo-worker",
      "uid": "b13fc143-6a3b-44b7-bb38-58d3e27e665a"
    },
    "pod": {
      "name": "workload-client-86945585f4-4vp5q",
      "uid": "b887b913-d942-4e81-ad63-8baf1d829c7e"
    },
    "serviceaccount": {
      "name": "workload-client",
      "uid": "513d3d79-a34a-4ae6-819d-d8ea58c51c09"
    }
  },
  "nbf": 1763376572,
  "sub": "system:serviceaccount:applications:workload-client"
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
./4-delete-cluster.sh
```
