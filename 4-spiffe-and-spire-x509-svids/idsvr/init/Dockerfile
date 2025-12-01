FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y openssl

WORKDIR /work
COPY entrypoint.sh /work/
COPY spiffe-helper /work/
COPY helper.conf   /work/

ENTRYPOINT ["/work/entrypoint.sh"]
