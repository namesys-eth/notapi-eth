// SPDX-License-Identifier: WTFPL.ETH
pragma solidity ^0.8.0;

import "./Interface.sol";
import "./Generator.sol";
import "./Ticker.sol"; // Ensure this is the correct import
import "./Utils.sol";

contract NotAPI is TickerManager {
    using Generator for *;
    using Utils for *;
    using LibString for *; // Updated to use LibString

    address public ENSWrapper;
    address public PubResolver;

    constructor() {
        supportsInterface[iENSIP10.resolve.selector] = true;
    }

    // Custom Errors
    error RequestNotImplemented(bytes4);
    error ResolverRequestFailed();
    error BadRequest();

    function resolve(bytes calldata name, bytes calldata request) external view returns (bytes memory result) {
        uint256 index;
        uint256 level;
        bytes[] memory labels = new bytes[](9);
        uint256 length;

        unchecked {
            while (name[index] > 0x0) {
                length = uint8(name[index++]);
                labels[level++] = name[index:index += length];
            }
        }
        // <x>--<x> prefix
        if (labels[0][1] == bytes1("-") && labels[0][1] == labels[0][2]) {
            if (labels[0][0] == labels[0][3]) {}
        }
        if (level == 4) {
            return resolve4(labels[0], labels[1]); // Call resolve4 for fourth-level domains
        } else if (level == 3) {
            return resolve3(labels[0]);
        } else if (level == 2) {
            return resolve2(name, request);
        } else {
            revert RequestNotImplemented(bytes4(request[:4]));
        }
    }

    // Resolve for second-level domains
    function resolve2(bytes calldata name, bytes calldata request) internal view returns (bytes memory) {
        if (PubResolver.checkInterface(iENSIP10.resolve.selector)) {
            return iENSIP10(PubResolver).resolve(name, request);
        }
        if (PubResolver.checkInterface(bytes4(request[:4]))) {
            (bool ok, bytes memory result) = PubResolver.staticcall(request);
            if (ok) {
                return result;
            }
            revert ResolverRequestFailed();
        }
        revert RequestNotImplemented(bytes4(request[:4]));
    }

    function resolve3(bytes memory label) public view returns (bytes memory) {
        bytes32 node = keccak256(label);
        address _addr = Tickers[node]._addr;
        uint256 _erc = Tickers[node]._erc;
        bytes memory ensData;
        if (_addr == address(0)) {
            if (label.length == 42 && label[1] == bytes1("x") && label[0] == bytes1("0")) {
                _addr = string(label).stringToAddress(); // Updated to use LibString
            } else if (ENS.recordExists(keccak256(abi.encodePacked(ENSRoot, node)))) {
                (address _ensAddr, address _owner, address _manager, address _resolver, bytes memory _err) =
                    getENSAddr(label);
                if (_ensAddr != address(0) && _err.length == 0) {
                    ensData = abi.encodePacked(
                        '"ENS":{"domain":"',
                        string(label),
                        '.eth","owner":"',
                        _owner.toHexStringChecksummed(),
                        '","manager":"',
                        _manager.toHexStringChecksummed(),
                        '","resolver":"',
                        _resolver.toHexStringChecksummed(),
                        '"},'
                    );
                    _addr = _ensAddr;
                }
            }
            if (_addr == address(0)) {
                return "Address Not Found".toError(label);
            }
        }
        if (_addr.code.length > 0) {
            if (_erc == 0) {
                if (_addr.isERC721()) {
                    _erc = 721;
                }
                if (_addr.isERC20()) {
                    _erc = 20;
                }
            }
            if (_erc > 0) {
                if (_erc == 20) {
                    return _addr.getERC20Info().toJSON();
                }
                if (_erc == 721) {
                    return _addr.getERC721Info().toJSON();
                }
            }
        }
        return getFeatured(_addr);
    }

    function resolve4(bytes memory labelA, bytes memory labelB) internal view returns (bytes memory) {
        // Resolve the first label
        address addrA = getAddressFromLabel(labelA);
        if (addrA == address(0)) {
            return "Address Not Found".toError(labelA);
        }

        // Resolve the second label
        address addrB = getAddressFromLabel(labelB);
        if (addrB == address(0)) {
            return "Address Not Found".toError(labelB);
        }

        // Return combined information or perform additional logic as needed
        return abi.encodePacked("Resolved:", addrA, addrB);
    }

    // Retrieve address from label
    function getAddressFromLabel(bytes memory label) internal view returns (address _addr) {
        bytes32 node = keccak256(label);
        _addr = Tickers[node]._addr;
        if (_addr == address(0)) {
            if (label.isAddr()) {
                return string(label).stringToAddress(); // Updated to use LibString
            }
            node = keccak256(abi.encodePacked(ENSRoot, node));
            if (ENS.recordExists(node)) {
                return resolveENS(node);
            }
        }
    }

    function getENSAddr(bytes memory label)
        internal
        view
        returns (address _addr, address _owner, address _manager, address _resolver, bytes memory _err)
    {
        bytes32 node = keccak256(abi.encodePacked(ENSRoot, keccak256(label)));
        _resolver = ENS.resolver(node);
        if (_resolver != address(0)) {
            if (_resolver.checkInterface(iResolver.addr.selector)) {
                _addr = iResolver(_resolver).addr(node);
            } else if (_resolver.checkInterface(iOverloadResolver.addr.selector)) {
                _addr = abi.decode(iOverloadResolver(_resolver).addr(node, 60), (address));
            } else if (iERC165(_resolver).supportsInterface(iENSIP10.OffchainLookup.selector)) {
                try iENSIP10(_resolver).resolve(
                    abi.encodePacked(uint8(label.length), label, uint8(3), "eth", uint8(0)),
                    abi.encodeWithSelector(iResolver.addr.selector, node)
                ) returns (bytes memory result) {
                    _addr = abi.decode(result, (address));
                } catch (bytes memory err) {
                    _err = err;
                }
            } else {
                _err = "Resolver does not support OffchainLookup";
            }
        }
        _manager = ENS.owner(node);
        _owner = ENSNFT.getNFTOwner(uint256(keccak256(label)));
    }

    // Resolve ENS to get the address
    function resolveENS(bytes32 hash) internal view returns (address) {
        bytes32 node = keccak256(abi.encodePacked(ENSRoot, hash));
        if (ENS.recordExists(node)) {
            address resolver = ENS.resolver(node);
            if (iERC165(resolver).supportsInterface(iResolver.addr.selector)) {
                return iResolver(resolver).addr(node);
            }
        }
        return address(0);
    }

    // Handle third-level domains
    function getAddrByLabelA(bytes memory label) public view returns (address _addr, uint256 erc) {
        bytes32 hash = keccak256(label);
        _addr = Tickers[hash]._addr;
        if (_addr == address(0)) {
            if ((label.length == 42 && label[1] == bytes1("x") && label[0] == bytes1("0"))) {
                _addr = string(label).stringToAddress(); // Updated to use LibString
            } else {
                hash = keccak256(abi.encodePacked(ENSRoot, hash));
                if (ENS.recordExists(hash)) {
                    address resolver = ENS.resolver(hash);
                    if (resolver != address(0)) {
                        try iResolver(resolver).addr(hash) returns (address payable addr) {
                            _addr = addr;
                        } catch {
                            try iENSIP10(resolver).resolve(
                                abi.encodePacked(uint8(label.length), label, hex"03", "eth", uint8(0)),
                                abi.encodeWithSelector(iResolver.addr.selector, hash)
                            ) returns (bytes memory result) {
                                _addr = abi.decode(result, (address));
                            } catch (bytes memory err) {
                                bytes4 off = bytes4(this.getBytes(err, 0, 4));
                                if (off == iENSIP10.OffchainLookup.selector) {
                                    //offchain = true;
                                }
                            }
                        }

                        if (resolver.checkInterface(iResolver.addr.selector)) {
                            _addr = iResolver(resolver).addr(hash);
                        }
                    }
                }
            }
        }

        if (_addr.code.length > 0) {
            if (_addr.isERC721()) {
                // return _addr.getERC721Info().toJSON();
            } else if (_addr.isERC20()) {
                // return _addr.getERC20Info().toJSON();
            }
        }
        if (_addr != address(0)) {
            // return getFeatured(_addr);
        }
        // return "Address Not Found".toError(label);
    }
}
