// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

library Utils {
    bytes16 internal constant b16 = "0123456789abcdef";
    bytes16 internal constant B16 = "0123456789ABCDEF";
    string internal constant B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function encodeLen(uint256 length) internal pure returns (bytes memory) {
        return (length < 128)
            ? abi.encodePacked(uint8(length))
            : bytes.concat(toBin(length % 128 + 128), toBin(length / 128));
    }

    function toBin(uint256 x) private pure returns (bytes memory b) {
        if (x > 0) return bytes.concat(toBin(x / 256), bytes1(uint8(x % 256)));
    }

    function toJSON(string memory _json) internal pure returns (bytes memory) {
        return bytes.concat(hex"e30101800400", encodeLen(bytes(_json).length), bytes(_json));
    }

    function encodeBase64(bytes memory data) internal pure returns (string memory result) {
        /// @dev Lookup :
        // https://github.com/Brechtpd/base64/blob/e78d9fd951e7b0977ddca77d92dc85183770daf4/base64.sol
        // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Base64.sol
        if (data.length == 0) return "";
        string memory table = B64;
        result = new string(4 * ((data.length + 2) / 3));
        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)
            for {
                let dataPtr := data
                let endPtr := add(data, mload(data))
            } lt(dataPtr, endPtr) {} {
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1)
            }
            switch mod(mload(data), 3)
            case 1 {
                mstore8(sub(resultPtr, 1), 0x3d)
                mstore8(sub(resultPtr, 2), 0x3d)
            }
            case 2 { mstore8(sub(resultPtr, 1), 0x3d) }
        }
    }

    function log10(uint256 value) internal pure returns (uint256 result) {
        unchecked {
            if (value >= 1e64) {
                value /= 1e64;
                result += 64;
            }
            if (value >= 1e32) {
                value /= 1e32;
                result += 32;
            }
            if (value >= 1e16) {
                value /= 1e16;
                result += 16;
            }
            if (value >= 1e8) {
                value /= 1e8;
                result += 8;
            }
            if (value >= 10000) {
                value /= 10000;
                result += 4;
            }
            if (value >= 100) {
                value /= 100;
                result += 2;
            }
            if (value >= 10) {
                ++result;
            }
        }
    }

    function hexStringToBytes(bytes memory input) internal pure returns (bytes memory output) {
        require((input).length % 2 == 0, "BAD_LENGTH");
        uint8 a;
        uint8 b;
        uint256 p = input[1] == bytes1("x") ? 1 : 0;
        uint256 k;
        unchecked {
            uint256 len = (input.length / 2) - p;
            output = new bytes(len);
            while (k < len) {
                b = uint8(input[2 * p]) - 48;
                a = (b < 10) ? b : b - 39;
                b = uint8(input[(2 * p++) + 1]) - 48;
                output[k++] = bytes1((a * 16) + ((b < 10) ? b : b - 39));
            }
        }
    }

    function bytesToHexString(bytes memory _buffer) internal pure returns (string memory) {
        unchecked {
            uint256 len = _buffer.length;
            bytes memory result = new bytes(len * 2);
            uint8 _b;
            for (uint256 i = 0; i < len; i++) {
                _b = uint8(_buffer[i]);
                result[i * 2] = b16[_b / 16];
                result[(i * 2) + 1] = b16[_b % 16];
            }
            return string.concat("0x", string(result));
        }
    }

    function stringToAddress(bytes memory _addr) internal pure returns (address) {
        require(_addr.length == 42 && _addr[1] == bytes1("x") && _addr[0] == bytes1("0"), "Invalid Address Format");
        return address(uint160(uint256(bytes32(hexStringToBytes(_addr)) >> 96)));
    }

    function toChecksumAddress(address _addr) internal pure returns (string memory) {
        unchecked {
            bytes memory _buffer = abi.encodePacked(_addr);
            bytes memory result = new bytes(40);
            bytes32 hash = keccak256(abi.encodePacked(bytesToHexString(_buffer)));
            uint256 d;
            uint256 r;
            for (uint256 i; i < 20; i++) {
                d = uint8(_buffer[i]) / 16;
                r = uint8(_buffer[i]) % 16;
                result[i * 2] = uint8(hash[i]) / 16 > 7 ? B16[d] : b16[d];
                result[i * 2 + 1] = uint8(hash[i]) % 16 > 7 ? B16[r] : b16[r];
            }
            return string.concat("0x", string(result));
        }
    }

    function uintToString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 len;
        unchecked {
            len = log10(value) + 1;
            bytes memory buffer = new bytes(len);
            while (value > 0) {
                buffer[--len] = bytes1(uint8(48 + (value % 10)));
                value /= 10;
            }
            return string(buffer);
        }
    }

    function stringToUint(bytes memory num) internal pure returns (uint256 result) {
        uint8 c;
        for (uint256 i; i < num.length; i++) {
            c = uint8(num[i]);
            if (c > 47 && c < 58) {
                result = result * 10 + (c - 48);
            } else {
                revert("Error: Not A Number");
            }
        }
    }

    function toError(string memory _msg) internal view returns (bytes memory) {
        return toJSON(
            string.concat(
                '{"error":"',
                _msg,
                '","timestamp":"',
                uintToString(block.timestamp),
                '","block":"',
                uintToString(block.number),
                '"}'
            )
        );
    }
}
