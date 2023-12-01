// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "./Interface.sol";
import "./Utils.sol";

library ENSData {
    using Utils for *;

    function getInfo(iENS ens, bytes32 _node, string memory _name) internal view returns (bytes memory) {
        return string.concat(
            '{"name":"',
            _name,
            '","namehash":"',
            abi.encodePacked(_node).bytesToHexString(),
            '","resolver":"',
            address(ens.resolver(_node)).toChecksumAddress(),
            '","manager":"',
            address(ens.owner(_node)).toChecksumAddress(),
            '","ttl":"',
            ens.ttl(_node).uintToString(),
            '","timestamp":"',
            (block.timestamp).uintToString(),
            '"}'
        ).toJSON();
        //'","block":"',
        //(block.number).uintToString(),
    }
}
