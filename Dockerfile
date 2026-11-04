# Static CGO_ENABLED=0 cross-compile on the DHI Go toolchain, scratch runtime,
# nonroot. Upstream publishes no container image; this fork exists to ship one
# built with a current toolchain.
FROM --platform=$BUILDPLATFORM dhi.io/golang:1.27.3-alpine-dev@sha256:d8099d992fae99616f09a95645a628de87e6d7883a2042a1f3200c536db8d091 AS builder

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
