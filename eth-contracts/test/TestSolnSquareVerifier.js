const SolnSquareVerifier = artifacts.require('SolnSquareVerifier');
const SquareVerifier = artifacts.require('SquareVerifier');

const proof = require('../../zokrates/proofs/proof_0.json');

contract("Test SolnSquareVerifier", accounts => {

    const account_one = accounts[0];

    const tokenId_one = 6;
    const tokenId_two = 77;
    const tokenId_three = 963;

    let squareVerifierContract;
    let solnSquareVerifier;

    before(async function () {
        squareVerifierContract = await SquareVerifier.new({from: account_one});
        solnSquareVerifier = await SolnSquareVerifier.new(squareVerifierContract.address, {from: account_one});
    });

    describe('Minting token', function () {

        it('should mint new ERC721 token', async function () {

            let result = await solnSquareVerifier.mintToken(
                account_one,
                tokenId_one,
                proof.proof.a,
                proof.proof.b,
                proof.proof.c,
                proof.inputs
            );
            
            let owner_tokenId_one = await solnSquareVerifier.ownerOf(tokenId_one);

            assert.equal("solutionAdded", result.logs[0].event, "Solution should be added when minting unique token");
            assert.equal("Transfer", result.logs[1].event, "Token should be transfered to caller");
            assert.equal(account_one, owner_tokenId_one, "Account one should be owner of token")
        });

        it('should NOT mint with duplicate solution', async function () {
            let mintStatus

            try {
                await solnSquareVerifier.mintToken(
                    account_one,
                    tokenId_two,
                    proof.proof.a,
                    proof.proof.b,
                    proof.proof.c,
                    proof.inputs
                );
            } catch (error) {
                mintStatus = error.reason;
            }

            assert.equal(mintStatus, "Solution already in use.", "Should not allow minting with duplicate solution");
        });
        
        it('should NOT mint with wrong solution', async function () {
            let mintStatus

            try {
                await solnSquareVerifier.mintToken(
                    account_one,
                    tokenId_three,
                    proof.proof.c,
                    proof.proof.b,
                    proof.proof.a,
                    proof.inputs
                );
            } catch (error) {
                mintStatus = error.reason;
            }

            assert.equal(mintStatus, "Proof is invalid", "Should not allow minting with wrong solution");
        });
    });

});