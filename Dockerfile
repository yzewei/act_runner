#FROM golang:1.23-alpine AS builder
FROM lcr.loongnix.cn/library/golang:1.22-alpine AS builder
# Do not remove `git` here, it is required for getting runner version when executing `make build`
RUN apk add --no-cache make git

COPY . /opt/src/act_runner
WORKDIR /opt/src/act_runner

RUN make clean && make build

FROM lcr.loongnix.cn/library/alpine:3.19
RUN apk add --no-cache git bash tini nodejs make && \
	wget http://cloud.loongnix.cn/releases/loongarch64/docker/cli/25.0.2/cli-25.0.2-static-abi2.0-bin.tar.gz && \
	tar xf cli-25.0.2-static-abi2.0-bin.tar.gz && cp -r cli-25.0.2-static-abi2.0-bin/* /usr/bin && \
	rm -rf cli-25.0.2-static-abi2.0-bin.tar.gz cli-25.0.2-static-abi2.0-bin/ ;

COPY --from=builder /opt/src/act_runner/act_runner /usr/local/bin/act_runner
COPY scripts/run.sh /opt/act/run.sh

ENTRYPOINT ["/sbin/tini","--","/opt/act/run.sh"]
