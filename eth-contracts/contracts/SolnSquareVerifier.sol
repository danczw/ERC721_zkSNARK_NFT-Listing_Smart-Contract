// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Verifier.sol";
import "./ERC721Mintable.sol";

// TODO define a contract call to the zokrates generated solidity contract <Verifier> or <renamedVerifier>
contract SquareVerifier is Verifier { 
    function verify(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[2] memory input
    ) public view returns (bool) {
        return super.verifyTx(a, b, c, input);
    }
}

// TODO define another contract named SolnSquareVerifier that inherits from your ERC721Mintable class
contract SolnSquareVerifier is propertyERC721Token {
    SquareVerifier private squareVerifier;
    
    constructor(address verifierAddress) propertyERC721Token(
        "Property zkSRNARK Token", "PZKT", "https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/"
    ) {
        squareVerifier = SquareVerifier(verifierAddress);
    }
    // TODO define a solutions struct that can hold an index & an address
    struct solution {
        uint256 tokenId;
        address to;
    }

    // TODO define an array of the above struct
    solution[] private solutionsArr; 

    // TODO define a mapping to store unique solutions submitted
    mapping(bytes32 => solution) solutionsMap;

    // TODO Create an event to emit when a solution is added
    event solutionAdded(uint tokenId, address to);

    // TODO Create a function to add the solutions to the array and emit the event
    function addSolution(address _to, uint256 _tokenId, bytes32 _index) public {
        solutionsArr.push(solution(_tokenId, _to));
        solutionsMap[_index] = solution(_tokenId, _to);
        emit solutionAdded(_tokenId, _to);
    }

    // TODO Create a function to mint new NFT only after the solution has been verified
    //  - make sure the solution is unique (has not been used before)
    //  - make sure you handle metadata as well as tokenSupply
    function mintToken(
        address _to,
        uint _tokenId,
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[2] memory input
    ) public returns (bool) {
        
        bytes32 _inputHash = keccak256(abi.encodePacked(a,b,c,input));
        require(solutionsMap[_inputHash].to == address(0), "Solution already in use.");
        require(squareVerifier.verify(a, b, c, input), "Proof is invalid");

        addSolution(_to, _tokenId, _inputHash);
        super._mintEnumerable(_to, _tokenId);
        super._setTokenURI(_tokenId);

        return true;
    }
}
