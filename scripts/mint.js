require('dotenv').config({ path: "../.env"});
const fs = require('fs');

const web3 = require("web3");
const HDWalletProvider = require("@truffle/hdwallet-provider");

const CONTRACT_DATA = require("../eth-contracts/build/contracts/SolnSquareVerifier.json");

const proof_path = '../zokrates/proofs/';
const proofs = fs.readdirSync(proof_path);

async function main() {
    console.log("Start minting...");
    let provider = new HDWalletProvider({
      mnemonic: process.env.METAMASK_MNEMONIC, // check .env and change to process.env.GANACHE_MNEMONIC for local testing
      providerOrUrl: process.env.RINKEBY_URL // check .env and change to process.env.GANACHE_URL for local testing
    });
    let thisAddress = provider.addresses[0];
    const web3Instance = new web3(provider);

    const contract = new web3Instance.eth.Contract(
        CONTRACT_DATA.abi,
        process.env.NFT_CONTRACT_ADDRESS, // check .env and change to process.env.GANACHE_CONTRACT_ADDRESS for local testing
        {gasLimit: "30000000"}
    );

    const contractOwner = await contract.methods
        .getOwner()
        .call({from: thisAddress});
    console.log(`Contract Owner: ${contractOwner}`);

    console.log("Checking total supply")
    let totalSupply = await contract.methods
        .totalSupply()
        .call({from: thisAddress});
    console.log(`Total supply before: ${totalSupply}`);

    console.log("To mint with these proofs:")
    console.log(proofs);

    let tokenId = Number(totalSupply) + 1;

    for (let i = 0; i < proofs.length; i++) {
        let proof = require(proof_path + proofs[i]);

        let response = await contract.methods
            .mintToken(
                thisAddress,
                tokenId,
                proof.proof.a,
                proof.proof.b,
                proof.proof.c,
                proof.inputs
            )
            .send({
                "from": thisAddress,
                "gas": 4712388,
                "gasPrice": 100000000000
            });

        console.log(`${proofs[i]}: ${response.status}`);
        tokenId += 1;
    }

    totalSupply = await contract.methods
        .totalSupply()
        .call({from: thisAddress});
    console.log(`Total supply after: ${totalSupply}`);
}

main().then(() => {
    console.log("Minting complete.");
    process.exit(0);
})