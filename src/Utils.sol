// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "./Interface.sol";
import "./CIDv1.sol";

//ERC1155 = 0Sxd9b67a26 | ERC721 = 0x80ac58cd

library Utils {
    bytes16 internal constant b16 = "0123456789abcdef";
    bytes16 internal constant B16 = "0123456789ABCDEF";
    error BadLength();
    function hexStringToBytes(
        bytes memory _in
    ) internal pure returns (bytes memory _out) {
        require(_in.length % 2 == 0, BadLength());
        unchecked {        
        uint8 a;
        uint8 b;
        uint256 i = _in[1] == bytes1("x") ? 1 : 0;
        uint j;
        uint256 k;
            uint256 len = (_in.length / 2) - i;
            _out = new bytes(len);
            while (k < len) {
                j = 2 * i++;
                b = uint8(_in[j]) - 48;
                a = b < 10 ? b : b - 39;
                b = uint8(_in[++j]) - 48;
                _out[k++] = bytes1(a * 16 + (b < 10 ? b : b - 39));
            }
        }
    }

    function bytesToHexString(
        bytes memory _in
    ) internal pure returns (string memory) {
        unchecked {
            uint256 len = _in.length;
            bytes memory _out = new bytes(len * 2);
            uint8 b;
            uint256 k;
            for (uint256 i = 0; i < len; i++) {
                b = uint8(_in[i]);
                k = i * 2;
                _out[k] = b16[b / 16];
                _out[k + 1] = b16[b % 16];
            }
            return string.concat("0x", string(_out));
        }
    }

    function bytesToHexString(
        bytes memory _buffer,
        bool prefix
    ) internal pure returns (string memory) {
        unchecked {
            uint256 len = _buffer.length;
            bytes memory result = new bytes(len * 2);
            uint8 _b;
            uint256 k;
            for (uint256 i = 0; i < len; i++) {
                _b = uint8(_buffer[i]);
                k = i * 2;
                result[k] = b16[_b / 16];
                result[k + 1] = b16[_b % 16];
            }
            return
                prefix ? string.concat("0x", string(result)) : string(result);
        }
    }

    function stringToAddress(
        bytes memory _addr
    ) internal pure returns (address) {
        return
            address(uint160(uint256(bytes32(hexStringToBytes(_addr)) >> 96)));
    }

    function toChecksumAddress(
        address _addr
    ) public pure returns (string memory) {
        bytes memory _buffer = abi.encodePacked(_addr);
        bytes memory result = new bytes(40);
        bytes32 hash = keccak256(
            abi.encodePacked(bytesToHexString(_buffer, false))
        );
        uint256 a;
        uint256 b;
        unchecked {
            for (uint256 i; i < 20; i++) {
                a = uint8(_buffer[i]) / 16;
                b = uint8(_buffer[i]) % 16;
                result[i * 2] = uint8(hash[i]) / 16 > 7 ? B16[a] : b16[a];
                result[i * 2 + 1] = uint8(hash[i]) % 16 > 7
                    ? B16[b]
                    : b16[b];
            }
        }
        return string.concat("0x", string(result));
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
    function stringToUint(
        bytes memory num
    ) internal pure returns (uint256 result) {
        unchecked {
            uint8 c;
            uint256 l = num.length;
            for (uint256 i; i < l; i++) {
                c = uint8(num[i]) - 48;
                if (c < 10) {
                    result = result * 10 + c;
                } else {
                    revert("Error: Not A Number");
                }
            }
        }
    }

    function idToUint(
        bytes memory id
    ) internal pure returns (bool ok, uint256 result) {
        if (id[0] != bytes1("i") || id[1] != bytes1("d")) {
            return (false, 0);
        }
        uint8 c;
        unchecked {
            for (uint256 i = 2; i < id.length; i++) {
                c = uint8(id[i]) - 48;
                if (c < 10) {
                    result = (result * 10) + c;
                } else {
                    return (false, type(uint).max);
                }
            }
            ok = true;
        }
    }

    //uint256 D = 1e8; // denominator

    function percentX1e8(uint256 n) external pure returns (string memory) {
        if (n > 99999999) {
            return "100%";
        } else if(n < 1000) {
            return "0.00%";
        }
        unchecked {
            uint256 i = n / 1e6;
            uint256 r = (n % 1e6) / 1e3; // round 3 decimals
            uint256 l = (n > 9999999) ? 7 : 6;
            bytes memory buf = new bytes(l);
            uint256 k = --l;
            buf[k] = bytes1("%");
            l -= 3;
            while (k > l) {
                buf[--k] = bytes1(uint8(48 + (r % 10)));
                r /= 10;
            }
            buf[--k] = bytes1(".");
            while (k > 0) {
                buf[--k] = bytes1(uint8(48 + (i % 10)));
                i /= 10;
            }
            return string(buf);
        }
    }
}
