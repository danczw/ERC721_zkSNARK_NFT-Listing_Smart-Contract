// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Verifier.sol";
import "./ERC721Mintable.sol";

contract SquareVerifier is Verifier { }

contract SolnSquareVerifier is Verifier, propertyERC721Token {
    SquareVerifier private squareContract;
    
    constructor(address payable verifierAddress) propertyERC721Token(
        "Property zkSNARK Token", "PZKT", "https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/"
    ) {
        squareContract = SquareVerifier(verifierAddress);
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

    /**
     * @dev mint new NFT only after the solution has been verified
     */
    function mintToken(
        address _to,
        uint256 _tokenId,
        uint256[2] memory _a,
        uint256[2][2] memory _b,
        uint256[2] memory _c,
        uint256[2] memory _input
    ) public returns (bool) {
        
        bytes32 _inputHash = keccak256(abi.encodePacked(_a,_b,_c,_input));
        require(solutionsMap[_inputHash].to == address(0), "Solution already in use.");
        require(squareContract.verifyTx(_a, _b, _c, _input), "Proof is invalid");

        addSolution(_to, _tokenId, _inputHash);
        super._mintEnumerable(_to, _tokenId);
        super._setTokenURI(_tokenId);

        return true;
    }
}
