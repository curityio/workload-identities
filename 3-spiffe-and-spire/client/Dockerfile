#
# A utility container that runs the SPIFFE helper in daemon mode to keep SVIDs up to date
#
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y curl jq openssl

WORKDIR /work
COPY spiffe-helper    /work/
COPY helper.conf      /work/

CMD ["/work/spiffe-helper"]
