// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "./Interface.sol";
import "./Utils.sol";

library TokenData {
    using Utils for *;

    function getInfo(iERC721 erc721) internal view returns (bytes memory) {
        return string.concat(
            '{"name":"',
            erc721.name(),
            '","contract":"',
            address(erc721).toChecksumAddress(),
            '","symbol":"',
            erc721.symbol(),
            '","totalsupply":"',
            (address(erc721).checkSupply()).uintToString(),
            '","timestamp":"',
            (block.timestamp).uintToString(),
            '"}'
        ).toJSON();
    }

    function getBalance(iERC721 erc721, address _addr) internal view returns (bytes memory) {
        return string.concat(
            '{"balance":"',
            (erc721.balanceOf(_addr)).uintToString(),
            '","totalsupply":"',
            (address(erc721).checkSupply()).uintToString(),
            '","owner":"',
            (_addr).toChecksumAddress(),
            '","timestamp":"',
            (block.timestamp).uintToString(),
            '"}'
        ).toJSON();
    }

    function getApprovedForAll(iERC721 erc721, address _owner, address _spender) internal view returns (bytes memory) {
        return string.concat(
            '{"approvedAll":"',
            (erc721.isApprovedForAll(_owner, _spender)) ? "true" : "false",
            '","owner":"',
            (_owner).toChecksumAddress(),
            '","spender":"',
            (_spender).toChecksumAddress(),
            '","timestamp":"',
            (block.timestamp).uintToString(),
            '"}'
        ).toJSON();
    }

    function getApprovedId(iERC721 erc721, uint256 _id) internal view returns (bytes memory) {
        return string.concat(
            '{"approved":"',
            (erc721.getApproved(_id)).toChecksumAddress(),
            '","owner":"',
            (erc721.ownerOf(_id)).toChecksumAddress(),
            '","id":"',
            (_id).uintToString(),
            '","timestamp":"',
            (block.timestamp).uintToString(),
            '"}'
        ).toJSON();
    }
}
