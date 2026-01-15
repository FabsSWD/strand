#!/bin/bash

# Health check for StrandDB
# Returns 0 if healthy, 1 if unhealthy

set -e

# Check if port is listening
if ! nc -z localhost 7878; then
    echo "StrandDB port 7878 is not listening"
    exit 1
fi

# TODO: Add more health checks
# - Check if database is accepting connections
# - Verify data directory is writable
# - Check memory usage

exit 0