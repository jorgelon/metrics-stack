FROM docker.io/golang:trixie

# Install Go tools to /usr/local/bin so they're accessible to all users
ENV GOBIN=/usr/local/bin

COPY build_from_source.sh /build_from_source.sh

# Install jsonnet tools
RUN go install -a github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@latest && \
    go install github.com/google/go-jsonnet/cmd/jsonnet@latest && \
    go install github.com/google/go-jsonnet/cmd/jsonnetfmt@latest

# Install Go-based yq (mikefarah/yq) - not the Python wrapper
RUN go install github.com/mikefarah/yq/v4@latest

# Install kustomize and other tools
RUN apt update && \
    apt install -y kustomize jq curl && \
    rm -rf /var/lib/apt/lists/*

# Make script executable
RUN chmod +x /build_from_source.sh

WORKDIR /workspace