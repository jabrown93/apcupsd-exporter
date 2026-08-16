# Static CGO_ENABLED=0 cross-compile on the DHI Go toolchain, scratch runtime,
# nonroot. Upstream publishes no container image; this fork exists to ship one
# built with a current toolchain.
FROM --platform=$BUILDPLATFORM dhi.io/golang:1.26.6-dev@sha256:b511696c1fb6929510c24d8ce66b90e7f9fc763082e5a8f73f778d7a177df93c AS builder

ARG TARGETOS
ARG TARGETARCH

WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -mod=mod -trimpath -ldflags='-w -s' -o /out/apcupsd_exporter ./cmd/apcupsd_exporter

FROM scratch

COPY --from=builder /out/apcupsd_exporter /apcupsd_exporter

USER 65532:65532
EXPOSE 9162
ENTRYPOINT ["/apcupsd_exporter"]
