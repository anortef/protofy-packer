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
# replace NODE_ENV=production pm2 start ecosystem.config.js && yarn monit with NODE_ENV=production pm2 start ecosystem.config.js in package.json
sed -i 's/NODE_ENV=production pm2 start ecosystem.config.js \&\& yarn monit/NODE_ENV=production pm2 start ecosystem.config.js/g' package.json
yarn prod-service

sudo shutdown -h now
