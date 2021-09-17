# Property Title Smart Contract

This is a Ethereum based Smart Contract for decentralized property title listing. Users are able to mint their own token to represent their tutke ti the property. Therefore, proof of ownership is needed. Zero-Knowledge Succinct Non-Interactive Argument of Knowledge (zk-SNARK) are used to create a verification system which can proof the user has title to the property without revealing specific information on the property. Once the token is verified the user is able to place it on a bkockchain market place (OpenSea) for others to purchase.

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

`npm install`

**ZoKrates Setup**

Run ZoKrates via docker container to implement zkSnarks:

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
    * `docker cp <docker name>:/home/zokrates/verifier.sol <path to project folder>/zokrates/zkSnark/`
    * `docker cp <docker name>:/home/zokrates/proving.key <path to project folder>/zokrates/zkSnark/` (optionally)
    * `docker cp <docker name>:/home/zokrates/verification.key <path to project folder>/zokrates/zkSnark/` (optionally)
    * `docker cp <docker name>:/home/zokrates/proof.json <path to project folder>/zokrates/zkSnark/` (optionally)
    * `docker cp <docker name>:/home/zokrates/witness <path to project folder>/zokrates/zkSnark/` (optionally)

---
###### *[part of my Blockchain Developer Nanodegree](https://www.udacity.com/course/blockchain-developer-nanodegree--nd1309)*
