#
# A utility container that can make curl requests to use workload identities and access tokens
#
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y curl jq

WORKDIR /work
COPY scripts/*.sh /work/

CMD ["/bin/sleep", "infinity"]
