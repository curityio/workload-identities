# Workload Identities with OAuth

[![Quality](https://img.shields.io/badge/quality-demo-red)](https://curity.io/resources/code-examples/status/)
[![Availability](https://img.shields.io/badge/availability-source-blue)](https://curity.io/resources/code-examples/status/)

Demonstrates modern cloud-native techniques to use hardened OAuth client credentials for workloads.\
Workloads can also potentially use sender-constrained OAuth access tokens to harden API requests.

## Prerequisites

Deployments use a local Kubernetes cluster so your local computer needs the following prequisites:

- Docker
- KIND 0.30 or later
- Kubernetes CLI (kubectl)
- Helm

Also get a license file for the Curity Identity Server from the [developer portal](https://developer.curity.io/).

## Deployment 1: Kubernetes Base System

The first deployment uses Kubernetes service account tokens with no need for additional infrastructure.\
Workloads can use projected service account tokens to get a JWT credential for authentication.

- [Run the Deployment](1-kubernetes-service-account-tokens/README.md)

## Deployment 2: Istio Service Mesh

The second deployment integrates the Curity Identity Server with an Istio service mesh.\
The mesh upgrades internal OAuth requests to use mutual TLS, to ensure request confidentiality.

- [Run the Deployment](2-istio-service-mesh/README.md)

## Deployment 3: SPIFFE and SPIRE with JWT SVIDs

The third deployment integrates the Curity Identity Server with SPIFFE and SPIRE.\
This deployment shows how workloads from any environment can use JWT SVIDs.

- [Run the Deployment](3-spiffe-and-spire-jwt-svids/README.md)

## Deployment 3: SPIFFE and SPIRE with X509 SVIDs

The fourth deployment also integrates the Curity Identity Server with SPIFFE and SPIRE.\
This deployment shows how workloads can use X509 SVIDs as an authentication credential.

- [Run the Deployment](4-spiffe-and-spire-x509-svids/README.md)

## More Information

- See the [Non Human Identities](https://curity.io/resources/machine-identities) tutorials for further details on the integrations.
- See the [Kubernetes Tutorials](https://curity.io/resources/kubernetes/) for further related content, on topics like adding ingress and data sources.
- Please visit [curity.io](https://curity.io/) for more information about the Curity Identity Server.
