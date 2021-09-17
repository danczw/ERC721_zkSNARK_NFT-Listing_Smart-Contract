const Verifier = artifacts.require('Verifier');
const proof = require('../../zokrates/zkSnark/proof.json');

// - use the contents from proof.json generated from zokrates steps
contract('Test Verifier', accounts => {
    let contract;

    describe('Verify Square', function () {
        
        beforeEach(async function () {
            contract = await Verifier.new();
        });
        
        // Test verification with correct proof
        it('verifies correct proof', async function () {
            let result = await contract.verifyTx.call(
                proof.proof.a,
                proof.proof.b,
                proof.proof.c,
                proof.inputs);

            assert.equal(result, true, "Proof should be verified");
        });
        
        // Test verification with incorrect proof
        it('rejects incorrect proof', async function () {
            let result = await contract.verifyTx.call(
                proof.proof.c,
                proof.proof.b,
                proof.proof.a,
                proof.inputs);

            assert.equal(result, false, "Proof should be falsified");
        });

    });
});