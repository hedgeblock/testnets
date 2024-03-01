# ⬡ berberis-1 testnet

## Details

| Chain ID          | `berberis-1`                                        |
|-------------------|-----------------------------------------------------|
| Launch Date       | 1st Feb, 2024                                       |
| Hedged version  | `v0.1.0`                                            |
| Genesis           | <https://rpc-berberis.hedgeblock.io/genesis>        |

> Add Hedge (Testnet) `berberis-1` to keplr: <https://chains.keplr.app/>

## Endpoints

Summary of the `berberis-1` endpoints:

| Service             | Url                                          |
|---------------------|----------------------------------------------|
| Public RPC          | <https://rpc-berberis.hedgeblock.io>         |
| Public LCD          | <https://lcd-berberis.hedgeblock.io>         |
| Public gRPC         | <https://grpc-berberis.hedgeblock.io>        |
| Hedge Seed Nodes  | |
| External Seed Nodes | `7879005ab63c009743f4d8d220abd05b64cfee3d@54.92.167.150:26656` |
| Explorers           | <https://berberis.hedgescan.io/>          |

### 🟣 Public Nodes

| Protocol | Url                                   |
|----------|---------------------------------------|
| RPC      | <https://rpc-berberis.hedgeblock.io>  |
| gRPC     | <https://grpc-berberis.hedgeblock.io> |
| REST     | <https://lcd-berberis.hedgeblock.io>  |

### 🌱 Seed

| Node          | ID                                                            |
|---------------|---------------------------------------------------------------|
| Berberis Seed  | |
| External Seed | `7879005ab63c009743f4d8d220abd05b64cfee3d@54.92.167.150:26656`|

Add the Node ID in your `p2p.seeds` section of you `config.toml`:

```toml
#######################################################
###           P2P Configuration Options             ###
#######################################################
[p2p]

# ...

# Comma separated list of seed nodes to connect to
seeds = "7879005ab63c009743f4d8d220abd05b64cfee3d@54.92.167.150:26656,"
```

### 🗺️ Explorer

The `berberis-1` testnet explorer is available at <https://berberis.hedgescan.io>

## Join the network

To join the Berberis network, check out the available resource from <https://docs.hedgeblock.io/run-a-node/overview>

## Genesis and Network Parameters

The testnet genesis can be found at <https://rpc-berberis.hedgeblock.io/genesis>.

The following modifications were made to the app state parameters:

- `gov.min_deposit` set to `6000000uhedge`
- `voting_params.voting_period` set to 172800s
- `staking.unbonding_time` set to `1814400s`
- `wasm.instantiate_default_permission` set to `Everybody` (yay! Go CosmWasm!)
