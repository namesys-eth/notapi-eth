// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

abstract contract Format {
    function Decode(
        bytes calldata _encoded
    ) external pure returns (string memory _path, string memory _domain) {
        uint256 n = 1;
        uint256 len = uint8(bytes1(_encoded[0]));
        bytes memory _label;
        _label = _encoded[1:n += len];
        _path = string(_label);
        _domain = _path;
        while (_encoded[n] > 0x0) {
            len = uint8(bytes1(_encoded[n:++n]));
            _label = _encoded[n:n += len];
            _domain = string.concat(_domain, ".", string(_label));
            _path = string.concat(string(_label), "/", _path);
        }
    }

    function Encode(
        bytes[] memory _names
    ) public pure returns (bytes32 _namehash, bytes memory _name) {
        uint256 i = _names.length;
        _name = abi.encodePacked(bytes1(0));
        _namehash = bytes32(0);
        unchecked {
            while (i > 0) {
                --i;
                _name = bytes.concat(
                    bytes1(uint8(_names[i].length)),
                    _names[i],
                    _name
                );
                _namehash = keccak256(
                    abi.encodePacked(_namehash, keccak256(_names[i]))
                );
            }
        }
    }

    function Encode(
        bytes calldata _input
    ) public pure returns (bytes32 _namehash, bytes memory _name) {
        uint256 len = _input.length;
        _name = abi.encodePacked(bytes1(0));
        bytes[] memory _names = new bytes[](7);
        uint256 k = 0;
        uint256 last = 0;
        for (uint256 i = 0; i < len; ++i) {
            if (_input[i] == bytes1(".")) {
                _names[k++] = _input[last:i];
                last = i;
            }
        }
        _names[k] = _input[last:];
        unchecked {
            while (k > 0) {
                --k;
                _name = bytes.concat(
                    bytes1(uint8(_names[k].length)),
                    _names[k],
                    _name
                );
                _namehash = keccak256(
                    abi.encodePacked(_namehash, keccak256(_names[k]))
                );
            }
        }
    }

    function getBytes(
        bytes calldata _b,
        uint256 _start,
        uint256 _end
    ) public pure returns (bytes memory) {
        return _b[_start:_end == 0 ? _b.length : _end];
    }
}
