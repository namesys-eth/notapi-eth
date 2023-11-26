// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "./Interface.sol";
import "./Utils.sol";

library TokenData {
    using Utils for *;

    function checkSupply(iERC721 erc721) internal view returns (uint256) {
        try erc721.totalSupply{gas: 99999}() returns (uint256 _supply) {
            return _supply;
        } catch {
            return 0;
        }
    }

    function _info(iERC721 erc721) internal view returns (bytes memory) {
        return string.concat(
            '{"name":"',
            erc721.name(),
            '","contract":"',
            address(erc721).toChecksumAddress(),
            '","symbol":"',
            erc721.symbol(),
            '","totalsupply":"',
            (erc721.totalSupply()).uintToString(),
            //'","decimal":"',
            //(erc721.decimals()).uintToString(),
            '","timestamp":"',
            (block.timestamp).uintToString(),
            '"}'
        ).toJSON();
        //'","block":"',
        //(block.number).uintToString(),
    }

    function _balance(iERC721 erc721, address _addr) internal view returns (bytes memory) {
        return string.concat(
            '{"balance":"',
            (erc721.balanceOf(_addr)).uintToString(),
            '","totalsupply":"',
            (erc721.totalSupply()).uintToString(),
            '","address":"',
            (_addr).toChecksumAddress(),
            '","timestamp":"',
            (block.timestamp).uintToString(),
            '"}'
        ).toJSON();
    }

    function _approvedForAll(iERC721 erc721, address _owner, address _spender) internal view returns (bytes memory) {
        return string.concat(
            '{"approved":"',
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
}
