const fs = require('fs');
const Verifier = artifacts.require('Verifier');

const proof_path = '../zokrates/proofs/';
const proofs = fs.readdirSync(proof_path);

// - use the contents from proof.json generated from zokrates steps
contract('Test Verifier', accounts => {
    let contract;

    describe('Verify Square', function () {
        
        beforeEach(async function () {
            contract = await Verifier.new();
        });
        
        // Test verification with correct proof
        it('verifies correct proof', async function () {
            for(let i = 0; i < proofs.length; i++) {
                let proof = require('../' + proof_path + proofs[i]);
                
                let result = await contract.verifyTx.call(
                    proof.proof.a,
                    proof.proof.b,
                    proof.proof.c,
                    proof.inputs);
                
                console.log('       ' + proofs[i]);
                assert.equal(result, true, `Proof ${proofs[i]} should be verified`);
            }            
        });
        
        // Test verification with incorrect proof
        it('rejects incorrect proof', async function () {
            let proof = require('../' + proof_path + proofs[0]);
            
            let result = await contract.verifyTx.call(
                proof.proof.c,
                proof.proof.b,
                proof.proof.a,
                proof.inputs);

            assert.equal(result, false, "Proof should be falsified");
        });

    });
});