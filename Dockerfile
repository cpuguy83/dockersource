FROM --platform=${BUILDPLATFORM} golang:1.18 AS build
WORKDIR /go/src/github.com/cpuguy83/dockersource
COPY go.mod .
COPY go.sum .
RUN \
    --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build,id=go-build-cache-${TARGETPLATFORM} \
    go mod download
COPY . .
ARG TARGETPLATFORM TARGETOS TARGETARCH TARGETVARIANT
ENV GOOS=${TARGETOS} GOARCH=${TARGETARCH}
SHELL ["/bin/bash", "-xec"]
RUN \
    --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build,id=go-build-cache-${TARGETPLATFORM} \
    GOARM=${TARGETVARIANT#v} CGO_ENABLED=0 go build .

FROM scratch
COPY --from=build /go/src/github.com/cpuguy83/dockersource/dockersource /