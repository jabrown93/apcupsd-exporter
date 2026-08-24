# Static CGO_ENABLED=0 cross-compile on the DHI Go toolchain, scratch runtime,
# nonroot. Upstream publishes no container image; this fork exists to ship one
# built with a current toolchain.
FROM --platform=$BUILDPLATFORM dhi.io/golang:1.27.0-alpine-dev@sha256:af973fb9b6ae481be6d36b582bc72ea2df5d4bb70109b6be89cad433113f82e0 AS builder

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
