#!/bin/bash
set -x
set -euo pipefail

DEBIAN_FRONTEND=noninteractive sudo apt-get update -y
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y curl

curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y nodejs git python3-venv
node -v
npm -v
cd
git clone https://github.com/Protofy-xyz/Protofy.git
cd Protofy
sudo npm i -g yarn
yarn install
yarn build
yarn package
nohup yarn prod-service &

# URL to check
URL="http://localhost:8000"

# Maximum wait time in seconds (5 minutes = 300 seconds)
TIMEOUT=300

# Interval (in seconds) between checks
INTERVAL=5

# Record the start time
START_TIME=$(date +%s)

while true; do
    # Perform the curl request silently, capturing only the HTTP status code
    STATUS_CODE=$(curl -vvv -s -o /dev/null -w "%{http_code}" "$URL")

    # Check if the status code is 200
    if [ "$STATUS_CODE" -eq 200 ]; then
        echo "Got 200! Exiting..."
        break
    fi

    # Calculate elapsed time
    CURRENT_TIME=$(date +%s)
    ELAPSED=$(( CURRENT_TIME - START_TIME ))

    # If we've reached or exceeded the timeout, stop
    if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
        echo "Timed out after $ELAPSED seconds without receiving 200. Exiting..."
        break
    fi

    # Otherwise, wait for the specified interval before trying again
    sleep "$INTERVAL"
done


sudo shutdown -h now
