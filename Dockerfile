FROM ubuntu:24.04

RUN apt update
RUN apt install -yy gcc g++ cmake

WORKDIR /src
COPY build.sh /build.sh
RUN chmod +x /build.sh

ENTRYPOINT ["/build.sh"]

