FROM swift:5.10-jammy AS builder
WORKDIR /build
COPY . .
RUN swift build -c release --disable-sandbox

FROM swift:5.10-jammy-slim
WORKDIR /app
COPY --from=builder /build/.build/release/App .
COPY --from=builder /usr/lib/swift/linux/*.so* /usr/lib/swift/linux/
EXPOSE 8080
ENTRYPOINT ["./App", "serve", "--hostname", "0.0.0.0", "--port", "8080"]
