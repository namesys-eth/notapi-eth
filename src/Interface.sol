// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;
/*
 * @title : NotAPI.eth
 * Proof of Concept* on-chain dynamic ENS contenthash generator
 * @author : freetib.eth, sshmatrix.eth
 * @github : https://github.com/namesys-eth/notapi-eth
 */

interface iERC165 {
    function supportsInterface(bytes4) external view returns (bool);
}

interface iERC173 {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);

    function transferOwnership(address _newOwner) external;
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

interface iERC721Metadata {
    function name() external view returns (string memory _name);

    function symbol() external view returns (string memory _symbol);

    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

interface iERC721Enumerable {
    function totalSupply() external view returns (uint256);

    function tokenByIndex(uint256 _index) external view returns (uint256);

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}

interface iERC721 is iERC721Metadata, iERC721Enumerable {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable;

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    function approve(address _approved, uint256 _tokenId) external payable;

    function setApprovalForAll(address _operator, bool _approved) external;

    function getApproved(uint256 _tokenId) external view returns (address);

    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

interface iERC1155Metadata is iERC721Metadata {
    function uri(uint256 _id) external view returns (string memory);
    function totalSupply(uint256 id) external view returns (uint256);
}

interface iERC1155 is iERC1155Metadata {
    event TransferSingle(
        address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value
    );
    event TransferBatch(
        address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values
    );
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    event URI(string _value, uint256 indexed _id);

    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;

    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external;

    function balanceOf(address _owner, uint256 _id) external view returns (uint256);

    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids)
        external
        view
        returns (uint256[] memory);

    function setApprovalForAll(address _operator, bool _approved) external;

    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
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

interface iERC7572 {
    function contractURI() external view returns (string memory);
}

interface iERC2981 is iERC165 {
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

interface iENS {
    function owner(bytes32 node) external view returns (address);

    function resolver(bytes32 node) external view returns (address);

    function ttl(bytes32 node) external view returns (uint64);

    function recordExists(bytes32 node) external view returns (bool);

    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
