// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

library CIDv1 {
    function encodeLength(uint256 length) internal pure returns (bytes memory) {
        return (length < 128)
            ? abi.encodePacked(uint8(length))
            : abi.encodePacked(bin((length % 128) + 128), bin(length / 128));
    }

    function bin(uint256 x) internal pure returns (bytes memory b) {
        if (x > 0) return abi.encodePacked(bin(x / 256), bytes1(uint8(x % 256)));
    }

    function toJSONCIDv1(bytes memory _data) internal pure returns (bytes memory) {
        return abi.encodePacked(hex"e30101800400", encodeLength(_data.length), _data);
    }
}
