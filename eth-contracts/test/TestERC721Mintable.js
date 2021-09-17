var ERC721MintableComplete = artifacts.require('propertyERC721Token');

contract('ERC721Mintable', accounts => {

    const name = "Property zkSRNARK Token";
    const symbol = "PZKT"
    const baseURI = "https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/"

    const account_one = accounts[0];
    const account_two = accounts[1];
    const account_three = accounts[2];
    const account_four = accounts[3];

    const tokenId_one = 6;
    const tokenId_two = 77;
    const tokenId_three = 963;
    const tokenId_four = 55822;
    const tokenId_five = 7799001;

    let contract;
    let mint_counter = 0;

    beforeEach(async function () {
        contract = await ERC721MintableComplete.new(
            name,
            symbol,
            baseURI,
            {from: account_one}
        );

        await Promise.all([    
            contract.mint(account_one, tokenId_one, {from: account_one}),
            contract.mint(account_two, tokenId_two, {from: account_one}),
            contract.mint(account_three, tokenId_three, {from: account_one}),
            contract.mint(account_three, tokenId_four, {from: account_one}),
            contract.mint(account_four, tokenId_five, {from: account_one})
        ])
        mint_counter = 5;
    })
    
    describe('match erc721 spec', function () {
        
        it('should return total supply', async function () { 
            const totalSupply = await contract.totalSupply.call();
            assert.equal(totalSupply, mint_counter, "Total supply not matching minted tokens")
        })

        it('should get token balance', async function () { 
            const account_one_bal = await contract.balanceOf(account_one);
            const account_two_bal = await contract.balanceOf(account_two);
            const account_three_bal = await contract.balanceOf(account_three);
            const account_four_bal = await contract.balanceOf(account_four);

            assert.equal(account_one_bal, 1, "Account one balance not matching")
            assert.equal(account_two_bal, 1, "Account two balance not matching")
            assert.equal(account_three_bal, 2, "Account three balance not matching")
        })

        // token uri should be complete i.e: https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/1
        it('should return token uri', async function () { 
            const base_tokenURI = await contract.baseTokenURI()

            const tokenOne_URI = await contract.tokenURI(tokenId_one);
            const tokenTwo_URI = await contract.tokenURI(tokenId_two);
            const tokenThree_URI = await contract.tokenURI(tokenId_three);
            const tokenFour_URI = await contract.tokenURI(tokenId_four);

            assert.equal(tokenOne_URI, base_tokenURI + tokenId_one.toString(), "Token one URI not matching");
            assert.equal(tokenTwo_URI, base_tokenURI + tokenId_two.toString(), "Token two URI not matching");
            assert.equal(tokenThree_URI, base_tokenURI + tokenId_three.toString(), "Token three URI not matching");
            assert.equal(tokenFour_URI, base_tokenURI + tokenId_four.toString(), "Token four URI not matching");
        })

        it('should transfer token from one owner to another', async function () { 
            await contract.approve(account_two, tokenId_one, {from: account_one});
            await contract.safeTransferFrom(account_one, account_two, tokenId_one, {from: account_one});
            
            const owner_tokenId_one = await contract.ownerOf(tokenId_one);
            
            assert.equal(owner_tokenId_one, account_two, "Ownership not transferred");
        })
    });

    describe('have ownership properties', function () {

        it('should fail when minting when address is not contract owner', async function () { 
            let mintStatus
            
            try {
                await contract.mint(account_four, tokenId_five, {from: account_two});
            } catch (error) {
                mintStatus = "mint failed"
            }

            assert.equal(mintStatus, "mint failed", "Should not allow minting by other than contract owner");
        })

        it('should return contract owner', async function () {
            const owner = await contract.getOwner.call();

            assert.equal(owner, account_one, "Owner is not account one");
        })

    });
})