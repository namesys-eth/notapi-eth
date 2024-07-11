// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "./Interface.sol";
import "./Utils.sol";
import "./Generator.sol";
import "./Manager.sol";

contract NotAPI is Manager {
    using Generator for *;
    using Utils for *;

    iENS public immutable ENS =
        iENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
    address public ExtraResolver;

    constructor() {
        supportsInterface[iENSIP10.resolve.selector] = true;
    }

    error RequestTypeNotImplemented();
    error ResolverRequestFailed();

    function resolve(
        bytes calldata name,
        bytes calldata request
    ) external view returns (bytes memory result) {
        uint256 level;
        uint256 ptr;
        uint256 len;
        bytes[] memory _labels = new bytes[](12);
        while (name[ptr] > 0x0) {
            len = uint8(bytes1(name[ptr:++ptr]));
            _labels[level++] = name[ptr:ptr += len];
        }
        if (level == 2) {
            if (
                iERC165(ExtraResolver).supportsInterface(
                    iENSIP10.resolve.selector
                )
            ) {
                return iENSIP10(ExtraResolver).resolve(name, request);
            } else if (
                iERC165(ExtraResolver).supportsInterface(bytes4(request[:4]))
            ) {
                bool ok;
                (ok, result) = ExtraResolver.staticcall(request);
                if (!ok) {
                    revert ResolverRequestFailed();
                }
            } else {
                revert RequestTypeNotImplemented();
            }
        }
        require(
            bytes4(request[:4]) == iResolver.contenthash.selector,
            "ONLY_CONTENTHASH"
        );
        if (level == 3) {
            //<*>.notapi.eth
            return resolve1(_labels[0]);
        } else if (level == 4) {} else {}
    }

    function getFeatured(
        address _addr
    ) public view returns (string memory _out) {
        uint256 len = Featured.length;
        _out = string.concat(
            '"eth":{"balance":"',
            (_addr.balance).uintToString(),
            '","symbol":"ETH","supply":"~","decimals":18,"erc":0}'
        );
        Ticker memory _token;
        // skip 0 in featured array, it's used for eth
        for (uint256 i = 1; i < len; i++) {
            _token = Tickers[keccak256(bytes(Featured[i]))];
            uint256 _bal = _addr.checkBalance(_token._addr);
            if (_bal > 0) {
                if (_token._erc == 20) {
                    iERC20 erc20 = iERC20(_token._addr);
                    _out = string.concat(
                        _out,
                        ',"',
                        Featured[i],
                        '":{"balance":"',
                        (_bal).uintToString(),
                        '","symbol":"',
                        erc20.symbol(),
                        '","decimals":',
                        (erc20.decimals()).uintToString(),
                        ',"supply":"',
                        (erc20.totalSupply()).uintToString(),
                        '","erc":20}'
                    );
                } else if (_token._erc == 721) {
                    iERC721 erc721 = iERC721(_token._addr);
                    _out = string.concat(
                        _out,
                        ',"',
                        Featured[i],
                        '":{"balance":"',
                        (_bal).uintToString(),
                        '","supply":"',
                        (erc721.totalSupply()).uintToString(),
                        '","symbol":"',
                        erc721.symbol(),
                        '","erc":721}'
                    );
                }
            }
        }
        _out = string.concat(
            '"address":"',
            _addr.toChecksumAddress(),
            '","tokens":{',
            _out,
            '}'
        );
    }

    function resolve1(bytes memory _label) public view returns (bytes memory) {
        address _addr;
        address ensOwner;
        bytes32 _hash = keccak256(_label);
        if (Tickers[_hash]._erc > 0) {
            _addr = Tickers[_hash]._addr;
        } else if (
            _label.length == 42 &&
            _label[1] == bytes1("x") &&
            _label[0] == bytes1("0")
        ) {
            _addr = _label.stringToAddress();
        } else {
            _hash = keccak256(abi.encodePacked(ENSRoot, _hash));
            if (ENS.recordExists(_hash)) {
                ensOwner = ENS.owner(_hash);
                address _resolver = ENS.resolver(_hash);
                try iResolver(_resolver).addr(_hash) returns (
                    address payable _a
                ) {
                    _addr = _a;
                } catch (bytes memory _e) {
                    return "BadRequest/L1/ENS".toError(_e);
                }
            } else {
                return "BadRequest/L1/ZeroAddr".toError();
            }
        }
        if (_addr.code.length > 0) {
            if (_addr.checkDecimals20() > 0) {
                return string.concat(_addr.erc20Data()).toJSON();
            } else if (_addr.interfaceCheck(type(iERC721).interfaceId)) {
                return string.concat().toJSON();
            } else if (_addr.interfaceCheck(type(iERC1155).interfaceId)) {
                return string.concat().toJSON();
            }
        }
        return getFeatured(_addr).toJSON();
    }

    function resolve2(
        bytes memory _labelA,
        bytes memory _labelB
    ) public view returns (bytes memory) {}

    error BadRequest();

    function getAddrData(
        address _addr,
        address _contract,
        uint16 _erc
    ) public view returns (bool ok, bytes memory _res) {
        if (_erc == 20) {
            iERC20 erc20 = iERC20(_contract);
            _res = bytes(
                string.concat(
                    '"balance":"',
                    (erc20.balanceOf(_addr)).uintToString(),
                    '","erc":20,"address":"',
                    _addr.toChecksumAddress(),
                    '","contract":"',
                    _contract.toChecksumAddress(),
                    '","symbol":"',
                    erc20.symbol(),
                    '","decimals":',
                    (erc20.decimals()).uintToString(),
                    ',"supply":"',
                    (erc20.totalSupply()).uintToString(),
                    '"'
                )
            );
        } else if (_erc == 721) {
            iERC721 erc721 = iERC721(_contract);
            _res = bytes(
                string.concat(
                    '"balance":"',
                    (erc721.balanceOf(_addr)).uintToString(),
                    '","erc":721,"address":"',
                    _addr.toChecksumAddress(),
                    '","contract":"',
                    _contract.toChecksumAddress(),
                    '","symbol":"',
                    erc721.symbol(),
                    '","supply":"',
                    (erc721.totalSupply()).uintToString(),
                    '"'
                )
            );
        } else if (_erc == 1155) {}
    }

    function getIDData(
        uint256 _id,
        address _contract,
        uint16 _erc
    ) public view returns (bool ok, bytes memory _res) {
        if (_erc == 721) {
            iERC721 erc721 = iERC721(_contract);
            //try erc20.decimals() returns (uint8 _dec) {
            //    if (_dec > 0) {
            address _owner = erc721.ownerOf(_id);
            _res = bytes(
                string.concat(
                    '"balance":"',
                    (erc721.balanceOf(_owner)).uintToString(),
                    '","owner":"',
                    (_owner).toChecksumAddress(),
                    '","erc":721,"contract":"',
                    _contract.toChecksumAddress(),
                    '","symbol":"',
                    erc721.symbol(),
                    '","supply":"',
                    (erc721.totalSupply()).uintToString(),
                    '"'
                )
            );
            //}
            //} catch (bytes memory _e) {
            //    return "Bad Request/1/Addr".toError(_e);
            //}
        } else if (_erc == 1155) {
            iERC1155 erc1155 = iERC1155(_contract);
            address _owner; // = erc1155.ownerOf(_id);
            _res = bytes(
                string.concat(
                    '"balance":"',
                    //(erc1155.balanceOf(_addr)).uintToString(),
                    '","erc":1155,"address":"',
                    //_addr.toChecksumAddress(),
                    '","contract":"',
                    _contract.toChecksumAddress(),
                    '","symbol":"',
                    erc1155.symbol(),
                    '","supply":"',
                    //(erc1155.totalSupply()).uintToString(),
                    '"'
                )
            );
        } else if (_erc == 1155) {}
    }

    function getType2A(
        uint16 _erc,
        address _addr,
        bytes memory _label
    ) public view returns (bytes memory _data) {
        uint16 _ercA;
        address _addrA;
        address _ensOwner;
        if (
            _label.length % 2 == 0 &&
            _label[1] == bytes1("x") &&
            _label[0] == bytes1("0")
        ) {
            if (_label.length == 10 || (_label.length - 10) % 64 == 0) {
                (bool ok, bytes memory _res) = _addr.getCalldata(_label);
                if (ok) {
                    return string(_res).toJSON();
                }
            } else if (_label.length == 42) {
                _addrA = _label.stringToAddress();
            }
        } else if (_label[1] == bytes1("d") && _label[0] == bytes1("i")) {
            (bool ok, uint256 id) = _label.idToUint();
            if (ok && (_erc == 1155 || _erc == 721)) {}
        }
        bytes32 _hash = keccak256(_label);
        if (_label.length < 42) {
            _hash = keccak256(abi.encodePacked(ENSRoot, _hash));
            if (ENS.recordExists(_hash)) {
                _ensOwner = ENS.owner(_hash);
                address _resolver = ENS.resolver(_hash);
                try iResolver(_resolver).addr(_hash) returns (
                    address payable _a
                ) {
                    _addr = _a;
                } catch (bytes memory _e) {
                    //_err = _e;
                }
            } else {
                //revert BadRequest();
            }
        } else if (
            _label.length == 42 &&
            _label[1] == bytes1("x") &&
            _label[0] == bytes1("0")
        ) {
            _addr = _label.stringToAddress();
        } else {
            //revert BadRequest();
        }

        if (_erc == 0 && _addr.code.length > 0) {
            if (iERC165(_addr).supportsInterface(type(iERC721).interfaceId)) {
                _erc = 721;
            } else if (
                iERC165(_addr).supportsInterface(type(iERC1155).interfaceId)
            ) {
                _erc = 1155;
            } else {
                try iERC20(_addr).totalSupply() returns (uint256 _supply) {
                    if (_supply > 0) {
                        _erc = 20;
                    }
                } catch (bytes memory _e) {
                    //_err = _e;
                }
            }
        }
        if (_erc == 0) {
            //revert BadRequest();
        }
    }

    function getType2B(
        bytes memory _label
    )
        public
        view
        returns (
            uint16 _erc,
            address _addr,
            address _ensOwner,
            bytes memory _err
        )
    {
        bytes32 _hash = keccak256(_label);
        if (Tickers[_hash]._erc > 0) {
            _addr = Tickers[_hash]._addr;
            _erc = Tickers[_hash]._erc;
        } else if (
            _label.length == 42 &&
            _label[1] == bytes1("x") &&
            _label[0] == bytes1("0")
        ) {
            _addr = _label.stringToAddress();
        } else {
            _hash = keccak256(abi.encodePacked(ENSRoot, _hash));
            if (ENS.recordExists(_hash)) {
                _ensOwner = ENS.owner(_hash);
                address _resolver = ENS.resolver(_hash);
                try iResolver(_resolver).addr(_hash) returns (
                    address payable _a
                ) {
                    if (_a == address(0)) {
                        _addr = _ensOwner;
                    } else {
                        _addr = _a;
                    }
                } catch (bytes memory _e) {
                    _err = _e;
                }
            } else {
                //revert BadRequest();
            }
        }
        if (_erc == 0 && _addr.code.length > 0) {
            if (iERC165(_addr).supportsInterface(type(iERC721).interfaceId)) {
                _erc = 721;
            } else if (
                iERC165(_addr).supportsInterface(type(iERC1155).interfaceId)
            ) {
                _erc = 1155;
            } else {
                try iERC20(_addr).totalSupply() returns (uint256 _supply) {
                    if (_supply > 0) {
                        _erc = 20;
                    }
                } catch (bytes memory _e) {
                    _err = _e;
                }
            }
        }
        if (_erc == 0) {
            //revert BadRequest();
        }
    }

    function getType(
        bytes memory _label
    ) public view returns (uint16 _erc, address _addr, bytes memory _err) {
        if (
            _label.length == 42 &&
            _label[1] == bytes1("x") &&
            _label[0] == bytes1("0")
        ) {
            _addr = _label.stringToAddress();
            if (_addr.code.length > 0) {
                if (
                    iERC165(_addr).supportsInterface(type(iERC721).interfaceId)
                ) {
                    _erc = 721;
                } else if (
                    iERC165(_addr).supportsInterface(type(iERC1155).interfaceId)
                ) {
                    _erc = 1155;
                } else {
                    try iERC20(_addr).totalSupply() returns (uint256 _supply) {
                        if (_supply > 0) {
                            _erc = 20;
                        }
                    } catch (bytes memory _e) {
                        _err = _e;
                    }
                }
            }
        } else {
            bytes32 _hash = keccak256(_label);
            if (Tickers[_hash]._erc > 0) {
                _addr = Tickers[_hash]._addr;
                _erc = Tickers[_hash]._erc;
            } else {
                _hash = keccak256(abi.encodePacked(ENSRoot, _hash));
                if (ENS.recordExists(_hash)) {
                    _erc = 137;
                    //address _resolver = ENS.resolver(_hash);
                    try iResolver(ENS.resolver(_hash)).addr(_hash) returns (
                        address payable _a
                    ) {
                        _addr = _a;
                    } catch (bytes memory _e) {
                        _err = _e;
                    }
                } else {
                    revert BadRequest();
                }
            }
        }
    }
}
