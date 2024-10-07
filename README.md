# [~~NOT~~API.ETH](https://NotAPI.eth.limo)

ENS wildcards based on-chain data resolver/generator.

## Registered Symbols

List of token symbols for API queries:

| Symbol | Type | Decimals | Featured | Address |
|--------|------|----------|----------|---------|
| eth | ether | 18 | Yes | N/A |
| weth | ERC20 | 18 | Yes | 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2 |
| dai | ERC20 | 18 | Yes | 0x6B175474E89094C44Da98b954EedeAC495271d0F |
| usdc | ERC20 | 6 | Yes | 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 |
| usdt | ERC20 | 6 | Yes | 0xdAC17F958D2ee523a2206206994597C13D831ec7 |
| link | ERC20 | 18 | No | 0x514910771AF9Ca656af840dff83E8264EcF986CA |
| uni | ERC20 | 18 | No | 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984 |
| bayc | ERC721 | N/A | Yes | 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D |
| azuki | ERC721 | N/A | Yes | 0xED5AF388653567Af2F388E6224dC7C4b3241C544 |
| doodle | ERC721 | N/A | No | 0x8a90CAb2b38dba80c64b7734e58Ee1dB38B8992e |
| moonbird | ERC721 | N/A | No | 0x23581767a106ae21c074b2276D25e5C3e136a68b |



Featured tokens are auto-included in balance responses.

## ~~NOT~~API Format

### Single Query: <*A>.notapi.eth
Format: <address | ens | symbol>.notapi.eth

Examples:
- ERC20: https://dai.notapi.eth.limo 
```json
{
    "ok": true,
    "time": "1717281407",
    "block": "20000000",
    "result": {
        "erc": 20,
        "decimals": 18,
        "supply": "3271711656415240826702150235",
        "contract": "0x6B175474E89094C44Da98b954EedeAC495271d0F",
        "name": "Dai Stablecoin",
        "symbol": "DAI"
    }
}
```

- ERC721: https://cryptopunk.notapi.eth.limo

```json
{
    "ok": true,
    "time": "1717281407",
    "block": "20000000",
    "result": {
        "erc": "721",
        "supply": "999",
        "contract": "0x.....",
        "name": "My NFT",
        "symbol": "MNFT"
    }
}
```

### Double Query: <*A>.<*B>.notapi.eth
Format: `<address|ens|id>`.`<token|symbol>`.notapi.eth.limo

Examples:
- ERC20: https://vitalik.dai.notapi.eth.limo
- ERC721: https://ensd.notapi.eth.limo

JSON Result (balance query):
```json
{
    "ok": true,
    "time": "1717281407",
    "block": "20000000",
    "result": {
        "erc": 20,
        "decimals": 18,
        "contract": "0x6B175474E89094C44Da98b954EedeAC495271d0F",
        "symbol": "DAI",
        "balance": "12345678901234567890",
        "address": "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"
    }
}
```

Responses are in JSON format with token details or balances.
