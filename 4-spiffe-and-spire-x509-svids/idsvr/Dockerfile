FROM curity.azurecr.io/curity/idsvr:latest

#
# Copy in XML configuration for this deployment
#
COPY build/*.xml /opt/idsvr/etc/init/

#
# Copy in JavaScript procedures
#
COPY build/client_credentials_token_issuer.js /opt/idsvr/etc/init/token-procedures/oauth-token-client-credentials/
