// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import 'openzeppelin-solidity/contracts/utils/Address.sol';
import 'openzeppelin-solidity/contracts/utils/Counters.sol';
import 'openzeppelin-solidity/contracts/utils/math/SafeMath.sol';
import 'openzeppelin-solidity/contracts/token/ERC721/IERC721Receiver.sol';
import "./Oraclize.sol";

contract Ownable {
    address private _owner;
    
    event OwnershipTransfered(address prevOwner, address newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransfered(msg.sender, msg.sender);
    }

    /**
     * @dev get current owner of contract
     */
    function getOwner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev modifier to restrict function access to only contract owner
     */
    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the owner can call this function");
        _;
    }

    /**
     * @dev transfer contract ownership and emit respective event
     * @param newOwner address of owner contract is transfered to
     * only callable by current owner
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Passed address is invalid");

        _owner = newOwner;
        emit OwnershipTransfered(msg.sender, newOwner);
    }
}

contract Pausable is Ownable {    
    /**
     * @dev status of contract
     */
    bool private _paused;

    event PausableStatus(bool _status, address _triggerAddress);

    constructor() Ownable() {
        _paused = false;
    }

    /**
     * @dev owner can pause contract
     */
    function setPausable(bool _newStatus) public onlyOwner {
        _paused == _newStatus;
        
        emit PausableStatus(_paused, msg.sender);
    }

    /**
     * @dev modifier to allow function to run when contract is paused
     */
    modifier onlyPaused()  {
        require(_paused == true, "Contract is not paused");
        _;
    }

    /**
     * @dev modifier to allow function to run when contract is running (!paused)
     */
    modifier onlyNotPaused() {
        require(_paused == false, "Contract is paused");
        _;
    }
}

contract ERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev a mapping of interface id to whether or not it's supported
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    /**
     * @dev A contract implementing SupportsInterfaceWithLookup
     * implement ERC165 itself
     */
    constructor () {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev implement supportsInterface(bytes4) using a lookup table
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev internal method for registering an interface
     */
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff);
        _supportedInterfaces[interfaceId] = true;
    }
}

contract ERC721 is Pausable, ERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from token ID to owner
    mapping (uint256 => address) private _tokenOwner;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to number of owned token
    // IMPORTANT: this mapping uses Counters lib which is used to protect overflow when incrementing/decrementing a uint
    // use the following functions when interacting with Counters: increment(), decrement(), and current() to get the value
    // see: https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/drafts/Counters.sol
    mapping (address => Counters.Counter) private _ownedTokensCount;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor () {
        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    /**
     * @dev get amount of owned tokens for account
     * @param owner account balance to be checked for
     */
    function balanceOf(address owner) public view returns (uint256) {
        return _ownedTokensCount[owner].current();
    }

    /**
     * @dev retrieve owner of a token if it exists
     * @param tokenId token ID owner to be retrieved for 
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId));
        return _tokenOwner[tokenId];
    }

    /**
     * @dev Approves another address to transfer the given token ID
     * @param to address to be approved for transferral
     * @param tokenId token ID the address gets transferral approved for
     */
    function approve(address to, uint256 tokenId) public {
        require(_exists(tokenId));

        address currOwner = _tokenOwner[tokenId];

        require(to != currOwner, "Receiver is same as token owner");
        require(msg.sender == currOwner || isApprovedForAll(currOwner, msg.sender), "Sender is not owner or approved");

        _tokenApprovals[tokenId] = to;

        emit Approval(msg.sender, to, tokenId);
    }

    /**
     * @dev Approves another address to transfer the given token ID
     * @param tokenId token ID for which approved addresses are returned
     * @return address which has approval
     */
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId));
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf
     * @param to operator address to set the approval
     * @param approved representing the status of the approval to be set
     */
    function setApprovalForAll(address to, bool approved) public {
        require(to != msg.sender);
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    /**
     * @dev Tells whether an operator is approved by a given owner
     * @param owner owner address which you want to query the approval of
     * @param operator operator address which you want to query the approval of
     * @return bool whether the given operator is approved by the given owner
     */
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev transfer token from one address to another
     * @param from address from wich the token will be transferred from
     * @param to address to which token will be address
     * @param tokenId token ID to be transferred
     */
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_exists(tokenId));
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved");

        _transferFrom(from, to, tokenId);
    }

    /**
     * @dev safe transfer token from one address to another
     * @param from address from wich the token will be transferred from
     * @param to address to which token will be address
     * @param tokenId token ID to be transferred
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        require(_exists(tokenId));
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev safe transfer token from one address to another
     * @param from address from wich the token will be transferred from
     * @param to address to which token will be address
     * @param tokenId token ID to be transferred
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        require(_exists(tokenId));
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "Not received");
    }

    /**
     * @dev Returns whether the specified token exists
     * @param tokenId uint256 ID of the token to query the existence of
     * @return bool whether the token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    /**
     * @dev Returns whether the given spender can transfer a given token ID
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     * is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev mint a new token and set owner
     * @param to address to which token will be addressed
     * @param tokenId token ID to be minted
     */
     function _mint(address to, uint256 tokenId) internal {

        require(_tokenOwner[tokenId] == address(0), "Token already exist");
        require(to != address(0), "Address invalid");
        
        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(msg.sender, to, tokenId);

    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address
     */
    function _transferFrom(address from, address to, uint256 tokenId) internal {

        require(_tokenOwner[tokenId] == from, "Sender is not token owner");
        require(to != address(0), "Receiving address is not valid");

        _tokenApprovals[tokenId] = address(0);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();
        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Internal function to invoke `onERC721Received` on a target address
     * The call is not executed if the target address is not a contract
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    /**
     * @dev Private function to clear current approval of a given token ID
     */
    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}

contract ERC721Enumerable is ERC165, ERC721 {
    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;
    /**
     * @dev Constructor function
     */
    constructor () {
        // register the supported interface to conform to ERC721Enumerable via ERC165
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    /**
     * @dev Gets the token ID at a given index of the tokens list of the requested owner
     * @param owner address owning the tokens list to be accessed
     * @param index uint256 representing the index to be accessed of the requested tokens list
     * @return uint256 token ID at the given index of the tokens list owned by the requested address
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        require(index < balanceOf(owner));
        return _ownedTokens[owner][index];
    }

    /**
     * @dev Gets the total amount of tokens stored by the contract
     * @return uint256 representing the total amount of tokens
     */
    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev Gets the token ID at a given index of all the tokens in this contract
     * Reverts if the index is greater or equal to the total number of tokens
     * @param index uint256 representing the index to be accessed of the tokens list
     * @return uint256 token ID at the given index of the tokens list
     */
    function tokenByIndex(uint256 index) public view returns (uint256) {
        require(index < totalSupply());
        return _allTokens[index];
    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to transferFrom, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _transferFromEnumeration(address from, address to, uint256 tokenId) internal {
        super._transferFrom(from, to, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);
    }

    /**
     * @dev Internal function to mint a new token
     * Reverts if the given token ID already exists
     * @param to address the beneficiary that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _mintEnumerable(address to, uint256 tokenId) internal {
        super._mint(to, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    /**
     * @dev Gets the list of token IDs of the requested owner
     * @param owner address owning the tokens
     * @return uint256[] List of token IDs owned by the requested address
     */
    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {
        return _ownedTokens[owner];
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the _ownedTokensIndex mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _ownedTokens[from].length - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        _ownedTokens[from].pop();

        // Note that _ownedTokensIndex[tokenId] hasn't been cleared: it still points to the old slot (now occupied by
        // lastTokenId, or just over the end of the array if the token was the last one).
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        _allTokens.pop();
        _allTokensIndex[tokenId] = 0;
    }
}

contract ERC721Metadata is ERC721Enumerable, usingOraclize {
    
    string private _name;
    string private _symbol;
    string private _baseTokenURI;

    mapping (uint256 => string) private _tokenURIs;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    constructor (string memory newName, string memory newSymbol, string memory newBaseTokenURI) {
        _name = newName;
        _symbol = newSymbol;
        _baseTokenURI = newBaseTokenURI;
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    // getter functions   
    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function baseTokenURI() external view returns (string memory) {
        return _baseTokenURI;
    }

    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        require(_exists(_tokenId));
        return _tokenURIs[_tokenId];
    }

    // TODO: Create an internal function to set the tokenURI of a specified tokenId
    // It should be the _baseTokenURI + the tokenId in string form
    // TIP #1: use strConcat() from the imported oraclizeAPI lib to set the complete token URI
    // TIP #2: you can also use uint2str() to convert a uint to a string
        // see https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol for strConcat()
    // require the token exists before setting
    function _setTokenURI(uint tokenId) internal {
        require(_exists(tokenId));
        string memory _tokenURI = usingOraclize.strConcat(_baseTokenURI, usingOraclize.uint2str(tokenId));
        _tokenURIs[tokenId] = _tokenURI;
    }

}

//  TODO's: Create CustomERC721Token contract that inherits from the ERC721Metadata contract. You can name this contract as you please
//  1) Pass in appropriate values for the inherited ERC721Metadata contract
//      - make the base token uri: https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/
//  2) create a public mint() that does the following:
//      -can only be executed by the contract owner
//      -takes in a 'to' address, tokenId, and tokenURI as parameters
//      -returns a true boolean upon completion of the function
//      -calls the superclass mint and setTokenURI functions

contract propertyERC721Token is ERC721Metadata {
    constructor(
        string memory name,
        string memory symbol,
        string memory baseURI
    ) ERC721Metadata(name, symbol, baseURI) {}

    /**
     * @dev public function to mint new tokens
     * @param tokenId uint256 ID of the token to be added to the tokens list
     * @param to owner address of the new token
     */
    function mint(address to, uint256 tokenId) public onlyOwner onlyNotPaused returns (bool) {
        super._mintEnumerable(to, tokenId);
        super._setTokenURI(tokenId);
        return true;
    }
}

