require('dotenv').config({ path: "../.env"})

const web3 = require("web3");
const HDWalletProvider = require("@truffle/hdwallet-provider");

const CONTRACT_DATA = require("../eth-contracts/build/contracts/SolnSquareVerifier.json");

async function main() {
    console.log("Start minting...");
    let provider = new HDWalletProvider({
      mnemonic: {phrase: process.env.METAMASK_MNEMONIC},
      providerOrUrl: process.env.RINKEBY_URL
    });
    let thisAddress = provider.addresses[0];
    const web3Instance = new web3(provider);

    const contract = new web3Instance.eth.Contract(
        CONTRACT_DATA.abi,
        process.env.NFT_CONTRACT_ADDRESS,
        {gasLimit: "1000000"}
    );

    console.log("Checking total supply")
    const totalSupply = await contract.methods
        .totalSupply()
        .call({from: thisAddress});
    console.log(`Total supply before: ${totalSupply}`);

    const args = process.argv.slice(2);
    console.log("To mint with these proofs:")
    console.log(args);

    let tokenId = Number(totalSupply) + 1;

    for (let i = 0; i < args.length; i++) {
        let jsonPath = args[i];
        const proofData = require(jsonPath);
        let response = await contract.methods
            .mintToken(
                thisAddress,
                tokenId,
                proofData.proof.a,
                proofData.proof.b,
                proofData.proof.c,
                proofData.inputs
            )
            .send({from: thisAddress});
        // console.log([
        //   thisAddress,
        //   tokenId,
        //   proofData.proof.a,
        //   proofData.proof.b,
        //   proofData.proof.c,
        //   proofData.inputs
        // ]);
        console.log(response)
        tokenId += 1;
    }

}

main().then(() => {
    console.log("Done minting.");
    process.exit(0);
})