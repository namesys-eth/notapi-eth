// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

interface iNotAPI {
    function lookupERC20(address _contract, address _allowed, bytes calldata _lookup)
        external
        view
        returns (bytes memory output);
    //function isCCIP(bytes calldata _lookup) external pure returns (bool);
    function __callbackERC20(bytes calldata _result, bytes calldata _extradata)
        external
        view
        returns (bytes memory _output);
}

interface iERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface iERC173 {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);
    function transferOwnership(address _newOwner) external;
}

interface iENS {
    function owner(bytes32 node) external view returns (address);
    function resolver(bytes32 node) external view returns (address);
    function ttl(bytes32 node) external view returns (uint64);
    function recordExists(bytes32 node) external view returns (bool);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface iENSIP10 {
    error OffchainLookup(address _to, string[] _gateways, bytes _data, bytes4 _callbackFunction, bytes _extradata);

    function resolve(bytes memory _name, bytes memory _data) external view returns (bytes memory);
}

interface iResolver {
    function contenthash(bytes32 node) external view returns (bytes memory);
    function addr(bytes32 node) external view returns (address payable);
    function pubkey(bytes32 node) external view returns (bytes32 x, bytes32 y);
    function text(bytes32 node, string calldata key) external view returns (string memory value);
    function name(bytes32 node) external view returns (string memory);
    function ABI(bytes32 node, uint256 contentTypes) external view returns (uint256, bytes memory);
    function interfaceImplementer(bytes32 node, bytes4 interfaceID) external view returns (address);
    function zonehash(bytes32 node) external view returns (bytes memory);
    function dnsRecord(bytes32 node, bytes32 name, uint16 resource) external view returns (bytes memory);
    function recordVersions(bytes32 node) external view returns (uint64);
    function approved(bytes32 _node, address _signer) external view returns (bool);
}

interface iOverloadResolver {
    function addr(bytes32 node, uint256 coinType) external view returns (bytes memory);
    function dnsRecord(bytes32 node, bytes memory name, uint16 resource) external view returns (bytes memory);
}

interface iERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256 balance);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    function transfer(address to, uint256 _balance) external;
}

interface iERC721 {
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _id) external view returns (address);
    function getApproved(uint256 _id) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

    function name() external view returns (string memory _name);
    function symbol() external view returns (string memory _symbol);
    function tokenURI(uint256 _id) external view returns (string memory);
    function totalSupply() external view returns (uint256);
}

interface iERC1155 {
    function balanceOf(address _owner, uint256 _id) external view returns (uint256);
    function ownerOf(uint256 _id) external view returns (address);
    function uri(uint256 _id) external view returns (string memory);

    function getApproved(uint256 _id) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

    function totalSupply(uint256 id) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}
