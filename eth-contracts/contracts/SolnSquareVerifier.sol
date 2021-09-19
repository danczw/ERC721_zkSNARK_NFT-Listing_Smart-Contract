// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Verifier.sol";
import "./ERC721Mintable.sol";

// contract SquareVerifier is Verifier { 
//     /**
//      * @dev verify solution to mint
//      */
//     function verify(
//         uint256[2] memory a,
//         uint256[2][2] memory b,
//         uint256[2] memory c,
//         uint256[2] memory input
//     ) public view returns (bool) {
//         return super.verifyTx(a, b, c, input);
//     }
// }

contract SolnSquareVerifier is Verifier, propertyERC721Token {
    // SquareVerifier private squareVerifier;
    
    constructor(address payable verifierAddress) propertyERC721Token(
        "Property zkSNARK Token", "PZKT", "https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/"
    ) {
        // squareVerifier = SquareVerifier(verifierAddress);
    }

    struct solution {
        uint256 tokenId;
        address to;
    }

    solution[] private solutionsArr; 

    mapping(bytes32 => solution) solutionsMap;

    event solutionAdded(uint tokenId, address to);

    /**
     * @dev add Solution to array of used solutions
     */
    function addSolution(address _to, uint256 _tokenId, bytes32 _index) public {
        solutionsArr.push(solution(_tokenId, _to));
        solutionsMap[_index] = solution(_tokenId, _to);
        emit solutionAdded(_tokenId, _to);
    }

    // TODO:
    function verify(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[2] memory input
    ) public view returns (bool) {
        return super.verifyTx(a, b, c, input);
    }

    /**
     * @dev mint new NFT only after the solution has been verified
     */
    function mintToken(
        address _to,
        uint256 _tokenId,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[2] memory input
    ) public returns (bool) {
        
        bytes32 _inputHash = keccak256(abi.encodePacked(a,b,c,input));
        require(solutionsMap[_inputHash].to == address(0), "Solution already in use.");
        // require(squareVerifier.verify(a, b, c, input), "Proof is invalid");
        require(verify(a, b, c, input), "Proof is invalid");

        addSolution(_to, _tokenId, _inputHash);
        super._mintEnumerable(_to, _tokenId);
        super._setTokenURI(_tokenId);

        return true;
    }
}
