// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "./Interface.sol";

library Utils {
    bytes16 internal constant b16 = "0123456789abcdef";
    bytes16 internal constant B16 = "0123456789ABCDEF";
    string internal constant B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    iENS public constant ENS = iENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);

    function isAddr(bytes memory _addr)  internal pure returns (bool) {
        return (_addr.length == 42 && _addr[0] == bytes1("0") && _addr[1] == bytes1("x"));
    }

    function isENS(bytes memory _eth) internal view returns (bool) {
        
    }
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

    function checkInterface(address _contract, bytes4 _interface) internal view returns (bool) {
        try iERC165(_contract).supportsInterface{gas: 66666}(_interface) returns (bool ok) {
            return ok;
        } catch {
            return false;
        }
    }

    function checkENSAddr(bytes[] memory _labels) internal view returns (address _addr, string memory _error) {
        uint len = _labels .length;
        bytes32 _node = keccak256(abi.encodePacked(bytes32(0), keccak256(_labels[--len])));
        bytes memory _name = abi.encodePacked(uint8(_labels[len].length), _labels[len], hex"00");
        address _resolver;
        while (len > 0){
            _node = keccak256(abi.encodePacked(_node, keccak256(_labels[--len])));
            _name = abi.encodePacked(uint8(_labels[len].length), _labels[len], _name);
            if(ENS.resolver(_node) != address(0)){
                _resolver = ENS.resolver(_node);
            }
        }
        if (checkInterface(_resolver, iResolver.addr.selector)) {
            _addr = iResolver(_resolver).addr(_node);
        } else if(checkInterface(_resolver, iENSIP10.resolve.selector)){
            try iENSIP10(_resolver).resolve(_name, abi.encodeWithSelector(iResolver.addr.selector, _node)) returns (bytes memory _data) {
                _addr = abi.decode(_data, (address));
            } catch (bytes memory _lookup) {
                //error OffchainLookup(address _to, string[] _gateways, bytes _data, bytes4 _callbackFunction, bytes _extradata);
                //iNotAPI(address(this)).formatLookup(_lookup);
                //return false;
            }
        } else {
            _error = "ERC20: Invalid ENS Setup";
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
        //require(_addr.length == 42 && _addr[1] == bytes1("x") && _addr[0] == bytes1("0"), "Invalid Address Format");
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
