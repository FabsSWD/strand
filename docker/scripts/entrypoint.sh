#!/bin/bash
set -e

# Function to handle signals
term_handler() {
    echo "Received SIGTERM, shutting down gracefully..."
    kill -TERM "$child" 2>/dev/null
    wait "$child"
    exit 0
}

# Set up signal handlers
trap term_handler SIGTERM SIGINT

# Create data directory if it doesn't exist
mkdir -p /data

# Set proper permissions
chown -R stranddb:stranddb /data

# Start the application in background
"$@" &
child=$!

# Wait for the application to exit
wait "$child"