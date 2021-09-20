# NFT ERC721

Ethereum based Smart Contract for decentralized NFT listing using the ERC721 smart contract standard and zkSNARK proofs.

---

## Overview

The example of real estate title listing is used in further explanation. This is the capstone project submission for my [Blockchain Developer Nanodegree](https://www.udacity.com/course/blockchain-developer-nanodegree--nd1309)

Users are able to mint their own token and thereby e.g. represent their title of the real estate property. Therefore, proof of ownership is needed. Zero-Knowledge Succinct Non-Interactive Argument of Knowledge (zk-SNARK - great introductory read by the Mina Foundation: ["What are zk-SNARKs?"](https://minaprotocol.com/blog/what-are-zk-snarks)) proofs are used to create a verification system which can proof the user has title to the property without revealing specific information on the property. Once the token is verified the user is able to place it on a bkockchain market place (OpenSea) for others to purchase.

--

## Metadata

 [x] Ethereum Smart Contract:
* Token Name: `Property zkSNARK Token`
* Token Symbol: `PZKT`
* Token Address: `0xa7b34fc279A7e046560a24ABfA5B14BBf2592db2` ([Etherscan Rinkeby](https://rinkeby.etherscan.io/address/0xa7b34fc279A7e046560a24ABfA5B14BBf2592db2))
* Token Creation: `Sep-19-2021 11:28:37 PM +UTC` ([Txn on Etherscan Rinkeby](https://rinkeby.etherscan.io/tx/0x824ae8d522e8aeed61f47e342663ec4bed2009fdd500f73190a63ce615bc370e))

 [x] OpenSea:
- PZKT: "Property zkSNARK Token" - [Storefront](https://testnets.opensea.io/collection/property-zksnark-token)
- Test Transfer Txn hash: [0x13495b98239b90055b07d834f4021f8f5c06cfb27d08e46f6a556e8063cd9513](https://rinkeby.etherscan.io/tx/0x13495b98239b90055b07d834f4021f8f5c06cfb27d08e46f6a556e8063cd9513) - New Owner [Danczw-Testing](https://testnets.opensea.io/Danczw-Testing)


---

## Setup

Setup for project development and related activities. The following resources have been used:

* [Remix - Solidity IDE](https://remix.ethereum.org/)
* [Truffle Framework](https://truffleframework.com/)
* [Ganache - One Click Blockchain](https://truffleframework.com/ganache)
* [Open Zeppelin ](https://openzeppelin.org/)
* [Interactive zero knowledge 3-colorability demonstration](http://web.mit.edu/~ezyang/Public/graph/svg.html)
* [Docker](https://docs.docker.com/install/)
* [ZoKrates](https://github.com/Zokrates/ZoKrates)

**Project Setup**

`npm install` to install dependencies.

**ZoKrates Setup** (optionally!)

Run ZoKrates via docker container to create own zkSnark proof, alternatively use provided _Verifier.sol_ contract. All files including 10 test proofs can also be found in [zokrates/](./zokrates/):

* run docker container `docker run -v <path to project folder>/zokrates/code:/home/zokrates/code -ti zokrates/zokrates //bin/bash`
* compile program `zokrates compile -i code/square/square.code`
* generate trusted setup `zokrates setup`
* compute witness `zokrates compute-witness -a 3 9`
* generate proof based on witness `zokrates generate-proof`
* export verifier smart contract `zokrates export-verifier` and `exit` to exit zokrates 

A verifier.sol contract should be created in the docker image to be used as zkSnark proof. Depending on OS, copy the created file from the image to your host.

For Windows:

* get container name `docker container ls` (under _NAMES_ column, far right)
* copy files:
```
docker cp <docker name>:/home/zokrates/verifier.sol <path to project folder>/zokrates/zkSnark/
docker cp <docker name>:/home/zokrates/proving.key <path to project folder>/zokrates/zkSnark/
docker cp <docker name>:/home/zokrates/verification.key <path to project folder>/zokrates/zkSnark/
docker cp <docker name>:/home/zokrates/proof.json <path to project folder>/zokrates/proofs/
docker cp <docker name>:/home/zokrates/witness <path to project folder>/zokrates/zkSnark/
```
* copy _Verifier.sol_ to [eth-contracts/contracts/](./eth-contracts/contracts)


---

## Testing

1. Make sure to have _Ganache_ running, development configurations (as per [truffle-config.js](./eth-contracts/truffle-config.js)):
2. _cd_ into [eth-contracts/](./eth-contracts): `cd eth-contracts`
3. Test zkSNARK and ERC721 individually:
```
truffle test test/TestERC721Mintable.js 
truffle test test/TestSquareVerifier.js
```
4. Test zkSNARK and ERC721 in final contract:
```
truffle test test/TestSolnSquareVerifier.js
```
5. (alternatively) test all contracts by running: `truffle test`

---

## Migration

**Migrating to Testnet**

For migrating contract, setup testnet in [truffle-config.js](./eth-contracts/truffle-config.js), i.e. rinkeby, and run `truffle migrate --network rinkeby`.


**Original Token Minting**

10 original tokens were minted using the [mint.js script](./scripts/mint.js):

1. set _.env_ vars according to [.env](./.env.example)
2. _cd_ into [scripts/](./scripts): `cd scripts`
3. set and choose development or test environment by setting process env variables (see script comments for details) in _mint.js_ script
4. run `node mint.js`

---

###### *[part of my Blockchain Developer Nanodegree](https://www.udacity.com/course/blockchain-developer-nanodegree--nd1309)*
