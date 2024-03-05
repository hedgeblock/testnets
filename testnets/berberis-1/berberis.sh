#!/bin/bash

echo -e "\e[1m\e[32m"
echo " ##    ## ######## #######        ######  ######## ";
echo " ##    ## ##       ##    ##    ##    ##   ##       ";
echo " ##    ## ##       ##     ##  ##          ##       ";
echo " ######## ######   ##     ##  ##   #####  ######   ";
echo " ##    ## ##       ##     ##  ##       ## ##       ";
echo " ##    ## ##       ##    ##    ##    ##   ##       ";
echo " ##    ## ######## #######      ######    ######## ";
echo -e "\e[0m"

sleep 2

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
HEDGE_PORT=26657
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export HEDGE_CHAIN_ID=berberis-1" >> $HOME/.bash_profile
echo "export HEDGE_PORT=${HEDGE_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$HEDGE_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$HEDGE_PORT\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux -y

# install go
if ! [ -x "$(command -v go)" ]; then
  ver="1.20"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bash_profile
  source ~/.bash_profile
fi

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
DIR="/usr/local/bin"
if [ ! -d "$DIR" ]; then
  sudo mkdir -p $DIR
fi
sudo wget -O /usr/local/bin/hedged https://github.com/hedgeblock/testnets/releases/download/v0.1.0/hedged_linux_amd64_v0.1.0 
sudo chmod +x /usr/local/bin/hedged
sudo wget -P /usr/lib https://github.com/CosmWasm/wasmvm/raw/main/internal/api/libwasmvm.x86_64.so

# config
hedged config chain-id $HEDGE_CHAIN_ID
hedged config keyring-backend test
hedged config node tcp://localhost:${HEDGE_PORT}

# init
hedged init $NODENAME --chain-id $HEDGE_CHAIN_ID

# download genesis and addrbook
wget -O ~/.hedge/config/genesis.json https://raw.githubusercontent.com/hedgeblock/testnets/release/dev/testnets/berberis-1/genesis/genesis.json

# set peers and seeds
SEEDS=""
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.hedge/config/config.toml

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0uhedge\"/" $HOME/.hedge/config/app.toml

# Set pruning
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "17"|' \
  $HOME/.zetacored/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.hedge/config/config.toml

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/hedged.service > /dev/null <<EOF
[Unit]
Description=hedge
After=network-online.target

[Service]
User=$USER
ExecStart=$(which hedged) start --home $HOME/.hedge
Environment=PIGEON_HEALTHCHECK_PORT=5757
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable hedged
sudo systemctl restart hedged

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u hedged -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${HEDGE_PORT}/status | jq .result.sync_info\e[0m"