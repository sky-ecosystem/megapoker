# MegaPoker
![Build Status](https://github.com/makerdao/megapoker/actions/workflows/.github/workflows/tests.yaml/badge.svg?branch=master)

Optimized Smart Contract to Poke (`poke`).

For Now, Hard Coded Addresses and Sequences. Easy for TechOps to Run.

MegaPoker current Mainnet Address: [0x727D37B7E185f4d57aEbb66a5e5CBd946Fa87999](https://etherscan.io/address/0x727D37B7E185f4d57aEbb66a5e5CBd946Fa87999#code)
**_TODO:_** Deploy the new MegaPoker contract and update its Mainnet Address.

# OmegaPoker

Extensible Poker for Goerli, Kovan and **Backup** for Mainnet.

The OmegaPoker will gather PIP Addresses from the [Ilk Registry](https://github.com/makerdao/ilk-registry) and Poke ALL Collaterals Without a Redeployment, at the expense of a little gas.

OmegaPoker Goerli Address: [0xD47850BB4Dd0E1ae4D362399f577a47D675cC830](https://goerli.etherscan.io/address/0xD47850BB4Dd0E1ae4D362399f577a47D675cC830#code)

OmegaPoker Mainnet Address: [0xDd538C362dF996727054AC8Fb67ef5394eC9b8b9](https://etherscan.io/address/0xDd538C362dF996727054AC8Fb67ef5394eC9b8b9#code)

## `OmegaPoker.refresh()`

Public function to reset all PIPs. Call this when a new collateral is onboarded to Goerli, Kovan and **Backup** for Mainnet.

## `OmegaPoker.poke()`

Public function to poke all ilks. Call after `refresh()`
