FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y curl jq

WORKDIR /work
COPY spiffe-helper    /work/
COPY helper.conf      /work/
COPY process-svids.sh /work/

CMD ["/work/spiffe-helper"]
