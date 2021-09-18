# NFT ERC721

This is a Ethereum based Smart Contract for decentralized NFT (e.g. real estate title) listing using the ERC721 smarc contract standard and zkSNARK proofs. Users are able to mint their own token to represent their tutke ti the property. Therefore, proof of ownership is needed. Zero-Knowledge Succinct Non-Interactive Argument of Knowledge (zk-SNARK) are used to create a verification system which can proof the user has title to the property without revealing specific information on the property. Once the token is verified the user is able to place it on a bkockchain market place (OpenSea) for others to purchase.

This is the capstone project submission for my [Blockchain Developer Nanodegree](https://www.udacity.com/course/blockchain-developer-nanodegree--nd1309)

## Metadata

 [x] Smart Contract:
* Token Name: `Property zkSNARK Token`
* Token Symbol: `PZKT`
* Token Address: `0x857373909D14ac37fbBC047c861bcdDaE9236bFB` ([Etherscan Rinkeby](https://rinkeby.etherscan.io/address/0x857373909d14ac37fbbc047c861bcddae9236bfb))
* Token Creation: `Sep-17-2021 11:35:06 PM +UTC`

 [ ] OpenSea:
- [Storefront links]()


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

`npm install` to install dependencies as per [package.json](./package.json)

**ZoKrates Setup** (optionally)

Run ZoKrates via docker container to create own zkSnarks proof, alternatively **use provided _Verifier.sol_ contract. All files needed can also be found in [zokrates/zkSnark/](./zokrates/zkSnark/)**:

* run docker container `docker run -v <path to project folder>/zokrates/code:/home/zokrates/code -ti zokrates/zokrates //bin/bash`
* compile program `zokrates compile -i code/square/square.code`
* generate trusted setup `zokrates setup`
* compute witness `zokrates compute-witness -a 3 9`
* generate proof based on witness `zokrates generate-proof`
* export verifier smart contract `zokrates export-verifier` and `exit` to exit zokrates 

A verifier.sol contract should be created in the image to be used as zkSnark proof. Depending on OS, copy the created file from the image to your host.

For Windows:

* get container name `docker container ls` (under _NAMES_ column, far right)
* copy files:
```
docker cp <docker name>:/home/zokrates/verifier.sol <path to project folder>/zokrates/zkSnark/
docker cp <docker name>:/home/zokrates/proving.key <path to project folder>/zokrates/zkSnark/
docker cp <docker name>:/home/zokrates/verification.key <path to project folder>/zokrates/zkSnark/
docker cp <docker name>:/home/zokrates/proof.json <path to project folder>/zokrates/zkSnark/
docker cp <docker name>:/home/zokrates/witness <path to project folder>/zokrates/zkSnark/
```

**Original Token Minting**

1. _cd_ into [scripts/](./scripts): `cd scripts`

~~2. Mint first 10 tokens by running:~~ 
```
node mint.js \
    ../zokrates/proofs/proof_0.json \
    ../zokrates/proofs/proof_1.json \
    ../zokrates/proofs/proof_3.json \
    ../zokrates/proofs/proof_4.json \
    ../zokrates/proofs/proof_5.json \
    ../zokrates/proofs/proof_6.json \
    ../zokrates/proofs/proof_7.json \
    ../zokrates/proofs/proof_8.json \
    ../zokrates/proofs/proof_9.json
```

---

## Testing

1. Make sure to have _Ganache_ running with the following configurations (as per [truffle-config.js](./eth-contracts/truffle-config.js)):

```JSON
development:
    host: "127.0.0.1",
    port: 7545,
    network_id: "*",
}
```
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

---
###### *[part of my Blockchain Developer Nanodegree](https://www.udacity.com/course/blockchain-developer-nanodegree--nd1309)*
