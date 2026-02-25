FROM golang:1.23-alpine AS builder

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -ldflags="-s -w" -o /out/mk-store-api ./cmd/api

FROM alpine:3.20

RUN adduser -D appuser
COPY --from=builder /out/mk-store-api /usr/local/bin/mk-store-api

USER appuser
EXPOSE 8081

ENTRYPOINT ["/usr/local/bin/mk-store-api"]
