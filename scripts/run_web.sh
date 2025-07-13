#!/bin/bash

# Flutter Web Development Script with Port Management
PORT=${1:-4028}
FALLBACK_PORT=4029

echo "Attempting to start Flutter web server on port $PORT..."

# Check if port is in use
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
    echo "Port $PORT is already in use. Attempting to kill the process..."
    
    # Kill the process using the port
    kill -9 $(lsof -ti:$PORT) 2>/dev/null
    
    # Wait a moment for the process to terminate
    sleep 2
    
    # Check if port is still in use
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
        echo "Could not free port $PORT. Using fallback port $FALLBACK_PORT..."
        PORT=$FALLBACK_PORT
    else
        echo "Port $PORT is now available."
    fi
else
    echo "Port $PORT is available."
fi

# Start Flutter web development server
echo "Starting Flutter web server on port $PORT..."
flutter run -d web-server --web-port $PORT --web-hostname 0.0.0.0