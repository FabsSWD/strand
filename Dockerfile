# Multi-stage build for minimal production image

# Build stage
FROM rust:1.92 AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy manifests
COPY Cargo.toml Cargo.lock ./
COPY format/Cargo.toml format/
COPY database/Cargo.toml database/
COPY cli/Cargo.toml cli/

# Cache dependencies by building an empty project
RUN mkdir format/src database/src cli/src && \
    echo "fn main() {}" > database/src/main.rs && \
    echo "fn main() {}" > cli/src/main.rs && \
    touch format/src/lib.rs && \
    cargo build --release && \
    rm -rf format/src database/src cli/src

# Copy source code
COPY format/ format/
COPY database/ database/
COPY cli/ cli/

# Build the actual application
RUN cargo build --release --bin stranddb

# Runtime stage
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -u 1000 stranddb && \
    mkdir -p /data /config && \
    chown -R stranddb:stranddb /data /config

# Copy binary from builder
COPY --from=builder /app/target/release/stranddb /usr/local/bin/stranddb

# Copy scripts
COPY docker/scripts/entrypoint.sh /usr/local/bin/
COPY docker/scripts/healthcheck.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/healthcheck.sh

# Copy default configuration
COPY docker/config/stranddb.toml /config/stranddb.toml

USER stranddb
WORKDIR /home/stranddb

# Expose ports
EXPOSE 7878 9090

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

# Set volumes
VOLUME ["/data", "/config"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["stranddb", "--config", "/config/stranddb.toml", "--data-dir", "/data"]