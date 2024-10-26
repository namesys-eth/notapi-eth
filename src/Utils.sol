// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "./Interface.sol";
import "./CIDv1.sol";
import "./LibString.sol"; // Ensure this is imported

//ERC1155 = 0Sxd9b67a26 | ERC721 = 0x80ac58cd
interface iERC20X {
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
}

library Utils {
    error BadLength();
    error BadHexString();

    // Removed uintToString and other functions that are already implemented in LibString

    /**
     * @dev Converts a lowercase hexadecimal string to a byte array.
     *      Only lowercase 'a'-'f' characters are supported.
     * @param _input Input hexadecimal bytes.
     * @return _out Resulting byte array.
     */
    function hexStringToBytes(bytes memory _input) internal pure returns (bytes memory _out) {
        uint256 inputLength = _input.length;
        require(inputLength % 2 == 0, BadLength());
        uint256 index = 0;
        if (inputLength > 2 && _input[0] == "0" && _input[1] == "x") {
            index = 2;
        } else if (inputLength > 2 && _input[0] == "0" && _input[1] == "X") {
            index = 1;
        }
        unchecked {
            _out = new bytes((inputLength - index) / 2);
            uint256 k;
            uint8 high;
            uint8 low;
            while (index < inputLength) {
                high = uint8(_input[index++]);
                low = uint8(_input[index++]);
                high -= high < 58 ? 48 : 87;
                low -= low < 58 ? 48 : 87;
                // GIGO
                //require(high < 16 && low < 16, BadHexString());
                _out[k++] = bytes1((high << 4) | low);
            }
        }
    }

    /**
     * @dev Converts a hexadecimal string to an Ethereum address.
     * @param _addr hexadecimal string representation of an address.
     * @return Ethereum address.
     */
    function stringToAddress(string memory _addr) internal pure returns (address) {
        return address(uint160(uint256(bytes32(hexStringToBytes(abi.encodePacked(_addr))) >> 96)));
    }

    error NotANumber();

    /**
     * @dev Converts a string representation of a number to uint256.
     * @param num byte array containing string representation of a number.
     * @return result uint256 value of input.
     */
    function stringToUint(bytes memory num) internal pure returns (uint256 result) {
        uint256 len = num.length;
        uint8 c;
        if (len > 78 || len == 0) return 0;
        unchecked {
            for (uint256 i; i < len; ++i) {
                c = uint8(num[i]) - 48;
                if (c > 9) {
                    revert NotANumber();
                }
                result = result * 10 + c;
            }
        }
    }

    /**
     * @dev Converts an 'id' prefixed string to uint256.
     * @param id byte array containing 'id' prefixed string.
     * @return ok A boolean indicating if conversion was successful.
     * @return result uint256 value of input if successful, otherwise 0 or max uint256.
     */
    function idToUint(bytes memory id) internal pure returns (bool ok, uint256 result) {
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
                    return (false, type(uint256).max);
                }
            }
            ok = true;
        }
    }

    /**
     * @dev Converts a number to a percentage string with up to 2 decimal places.
     * @param n number to convert (assumed to be scaled by 1e8).
     * @return A string representation of percentage.
     */
    function percent1e8(uint256 n) internal pure returns (string memory) {
        if (n >= 1e8) {
            return "100%";
        } else if (n < 1e3) {
            return "0.00%";
        }
        unchecked {
            uint256 i = n / 1e6;
            uint256 r = (n % 1e6) / 1e3; // round down to 3 decimals
            uint256 k = (n > 9999999) ? 7 : 6;
            bytes memory buf = new bytes(k);
            buf[--k] = "%";
            buf[--k] = bytes1(uint8(48 + (r % 10)));
            r /= 10;
            buf[--k] = bytes1(uint8(48 + (r % 10)));
            r /= 10;
            buf[--k] = bytes1(uint8(48 + (r % 10)));
            buf[--k] = ".";
            while (k > 0) {
                buf[--k] = bytes1(uint8(48 + (i % 10)));
                i /= 10;
            }
            return string(buf);
        }
    }

    /**
     * @dev Converts a bytes input with length divisible by 4 into a bytes4 array.
     * @param input input bytes array (must have length divisible by 4).
     * @return result resulting bytes4 array.
     */
    function bytesToBytes4Array(bytes memory input) internal pure returns (bytes4[] memory result) {
        uint256 len = input.length;
        if (len % 4 != 0) revert BadLength();

        len /= 4;
        result = new bytes4[](len);

        assembly {
            let resultPtr := add(result, 0x20)
            let inputPtr := add(input, 0x20)
            for { let i := 0 } lt(i, len) { i := add(i, 1) } {
                mstore(resultPtr, mload(inputPtr))
                resultPtr := add(resultPtr, 0x20)
                inputPtr := add(inputPtr, 0x04)
            }
        }
    }

    //
    function checkInterface(address _addr, bytes4 id) internal view returns (bool) {
        if (_addr.code.length == 0) {
            return false;
        }
        try iERC165(_addr).supportsInterface(id) returns (bool ok) {
            return ok;
        } catch {
            return false;
        }
    }

    function isERC721(address _addr) internal view returns (bool) {
        try iERC165(_addr).supportsInterface(type(iERC721).interfaceId) returns (bool ok) {
            return ok;
        } catch {
            return false;
        }
    }

    function isERC20(address _addr) internal view returns (bool) {
        try iERC20(_addr).decimals() returns (uint8 _decimals) {
            return _decimals > 0;
        } catch {
            return false;
        }
    }

    function getNFTOwner(iERC721 _erc721, uint256 _id) internal view returns (address) {
        try _erc721.ownerOf(_id) returns (address _owner) {
            return _owner;
        } catch {
            return address(0);
        }
    }
}
