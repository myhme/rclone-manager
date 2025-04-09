# --- Build Stage ---
FROM golang:1.23-alpine AS build

WORKDIR /app

# Copy go module files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the application
# Ensure entrypoint.sh is copied here if it's part of the source code context
COPY src/entrypoint.sh ./entrypoint.sh
RUN go build -o rclone-manager ./cmd/main.go


# --- Final Stage ---
FROM alpine:latest

# Install necessary packages
RUN apk add --no-cache \
    fuse3 \
    curl \
    rclone \
    su-exec # Keep su-exec just in case, though not used in final entrypoint

# Define the GID and UID
ARG RCLONE_GID=1001
ARG RCLONE_UID=1001

# Create the group and user
# Use '-S' for adduser to create a system user which is often preferred for services
RUN addgroup -g $RCLONE_GID rclonemanager && \
    adduser -u $RCLONE_UID -G rclonemanager -D -S -s /bin/sh rclonemanager

# Create data and cache directories and set ownership
# Cache dir is needed for Rclone VFS Cache Mode if used
RUN mkdir -p /data /caches/rclone && \
    chown rclonemanager:rclonemanager /data /caches/rclone

# Create symbolic link for fusermount
RUN ln -s /usr/bin/fusermount3 /usr/bin/fusermount

# Copy the built application from the build stage
COPY --from=build /app/rclone-manager /usr/local/bin/rclone-manager

# Copy the entrypoint script from the build stage to a suitable location
COPY --from=build /app/entrypoint.sh /usr/local/bin/entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Allow non-root users to use FUSE's allow_other option
RUN echo "user_allow_other" >> /etc/fuse.conf

# Switch to the non-root user
USER rclonemanager

# Set the entrypoint to the script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
