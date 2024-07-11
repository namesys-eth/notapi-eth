<sub>I can't Believe It's </sub> 
# NotAPI.eth
## https://i.Cant.Believe.its.NotAPI.eth.limo
### Web3 serverless on-chain data resolver/generator API using ENS wildcards.

## Reg'd Symbols 
|Name | Symbol | Type | Featured | Address | 
|--|--|--|--|--|
|Ether |eth|ether|True|~|
|Wrapped Ether|weth|ERC20|True|0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2|
|DAI Stablecoin|dai|ERC20|True|0x6B175474E89094C44Da98b954EedeAC495271d0F|
|USDC|usdc|ERC20|True|0x...|
|USDT|usdt|ERC20|True|0x...|
|ENS Token|ens|ERC20|True|0x...|
|ENS Domain|*ensd|ERC721|True|0x...||
|Wrapped ENS Domain|*wensd|ERC1155|false|0x...|

## Level 2 : <*>.notapi.eth.limo
### Format: <0xaddr|ens|sym> 
### Examples:
#### ERC20:
* https://0x6b175474e89094c44da98b954eedeac495271d0f.notapi.eth.limo
* https://dai.notapi.eth.limo
#### JSON Result :  
```json
{
    "ok": true,
    "time": "1717281407",
    "block": "20000000",
    "erc": "20",
    "supply": "3271711656415240826702150235",
    "decimals": "18",
    "contract": "0x6B175474E89094C44Da98b954EedeAC495271d0F",
    "name": "Dai Stablecoin",
    "symbol": "DAI"
}
```
#### ERC721:
* https://0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2.notapi.eth.limo
* https://ensd.notapi.eth.limo

#### ERC1155:
* https://0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2.notapi.eth.limo
* https://wensd.notapi.eth.limo


## Level 3 : <*A>.<*B>.notapi.eth

Format: <0xaddr|ens|id<num>>.<0xaddr|sym>.notapi.eth.limo 

### Examples:
#### ERC20:
* https://vitalik.0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2.notapi.eth.limo
* https://vitalik.weth.notapi.eth.limo

#### ERC721:
* https://0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2.notapi.eth.limo
* https://ensd.notapi.eth.limo

#### ERC1155:
* https://0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2.notapi.eth.limo
* https://wensd.notapi.eth.limo


`<*>` is sub domain label.

this label can be:

a) any regd symbol OR 
> eg, dai.notapi.eth or weth.notapi.eth

b) any ens domain label OR
> eg, vitalik.notapi.eth or virgil.notapi.eth

c) any address
> 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2.notapi.eth


## Level 3 : <\*>.<\*>.notapi.eth

first `<*>` is sub-sub domain label A, and second `<*>` is sub domain label B.

### Label A must be :  
a) any EOA address OR
> eg, <0xaddress>.\<B>.notapi.eth

b) any ENS domain label or
> eg, <vitalik>.\<B>.notapi.eth

c) any 0x prefixed hex string with 10 || >=2+4+64 length
> eg, 0x<abi.encodeWithSelector(iERC20.balanceOf.selector, address)>.\<B>.notapi.eth


### Label B must be : 
a) any reg'd symbols
> eg, \<A>.dai.notapi.eth

b) any erc20|721|1155 contract

## ERC20
* prefix : erc20
* format : `erc20.\<token>.\<function>.\<input..>.notapi.eth`

## Examples  
### Token Info: 
a) Registerd Symbol: https://erc20.dai.notapi.eth.limo

b) Address: https://erc20.0x6b175474e89094c44da98b954eedeac495271d0f.notapi.eth.limo 
```json
{
    "name": "Dai Stablecoin",
    "totalsupply": "3637675937363044499063709332",
    "symbol" : "DAI",
    "decimal" : 18,
    //"DAI" : "3637675937.363044499063709332",
    //"contract":"0x6B175474E89094C44Da98b954EedeAC495271d0F"
}
```
* Total Supply : https://erc20.0x6b175474e89094c44da98b954eedeac495271d0f.totalsupply.notapi.eth.limo
* Decimal : https://erc20.dai.decimal.notapi.eth.limo
* Name : https://erc20.0x6b175474e89094c44da98b954eedeac495271d0f.name.notapi.eth.limo
* Symbol : https://erc20.0x6b175474e89094c44da98b954eedeac495271d0f.symbol.notapi.eth.limo
> all of above requests return full token info

### Balance: 
a) address : https://erc20.dai.balanceof.0xd8da6bf26964af9d7eed9e03e53415d37aa96045.notapi.eth.limo

b) ENS Domain : https://erc20.dai.balanceof.vitalik.eth.notapi.eth.limo

c) ENS Subdomain : https://erc20.dai.balanceof.sub.vitalik.eth.notapi.eth.limo
> ?? ENS options return balance of owner??, NOT the ETH address set in resolver
> ??supporting on-chain resolved address is easy, adding CCIP-read will be bit complicated but doable.
```json
{
    "balance": "1818872440674356221452",
    "symbol" : "DAI",
    "decimal" : 18,
    //"DAI" : "1818.872440674356221452"
}
```
### Allowance : 
a) Address : https://erc20.dai.allowance.0xd8da6bf26964af9d7eed9e03e53415d37aa96045.0xb8c2c29ee19d8307cb7255e1cd9cbde883a267d5.notapi.eth.limo
b) ENS domain : https://erc20.dai.allowance.virgil.eth.vitalik.eth.notapi.eth.limo
c) ENS subdomain : https://erc20.dai.allowance.sub.virgil.eth.sub.vitalik.eth.notapi.eth.limo

```json
{
    "allowance": "1818872440674356221452",
    "symbol" : "DAI",
    "decimals" : 18,
}
```

## NFT (ERC721)
...

> similar pattern for erc721& erc1155

> alt prefix to add for extra? or let it be fixed?  
erc20.dai...notpai.eth is same as token.dai...notapi.eth
erc721.0xaddress... or erc721.0xaddress.. is same as nft.0xaddress...notapi.eth
^ we can check if contract is erc721/1155.

ens.owner.. type can be special class for ENS only.