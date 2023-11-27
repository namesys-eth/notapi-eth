// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "./Interface.sol";
import "./Utils.sol";
import "./ERC20Data.sol";

contract NotAPI is iERC173, iERC165, iNotAPI {
    using Utils for *;
    using ERC20Data for iERC20;

    iENS public immutable ENS = iENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);

    address public owner;
    /// @dev : ERC165 interface check
    mapping(bytes4 => bool) public supportsInterface;
    /// @dev : Map token symbol to token address
    mapping(bytes32 => address) public TokenMap;
    /// @dev : Map function name to bytes4 selector
    mapping(bytes32 => bytes4) public FunctionMap;

    constructor() {
        TokenMap[bytes32(bytes("dai"))] = address(0); //set DAI token address here
        TokenMap[bytes32(bytes("weth"))] = address(0); //set WETH token address here
        TokenMap[bytes32(bytes("usdc"))] = address(0); //set USDC token address here
        TokenMap[bytes32(bytes("ens"))] = address(0); //set ENS token address here

        supportsInterface[iERC165.supportsInterface.selector] = true;
        supportsInterface[iENSIP10.resolve.selector] = true;
        supportsInterface[type(iERC173).interfaceId] = true;

        FunctionMap["name"] = iERC20.name.selector;
        FunctionMap["symbol"] = iERC20.symbol.selector;
        FunctionMap["balanceof"] = iERC20.balanceOf.selector;
        FunctionMap["allowance"] = iERC20.allowance.selector;
        FunctionMap["totalsupply"] = iERC20.totalSupply.selector;
        FunctionMap["decimals"] = iERC20.decimals.selector;

        FunctionMap["tokenuri"] = iERC721.tokenURI.selector;
        FunctionMap["ownerof"] = iERC721.ownerOf.selector;
        FunctionMap["getapproved"] = iERC721.getApproved.selector;
        FunctionMap["isapprovedforall"] = iERC721.isApprovedForAll.selector;

        FunctionMap["uri"] = iERC1155.uri.selector;
    }
    //error CallbackFailed();

    error CallbackFailed(bytes);

    function __callback1(bytes calldata _result, bytes calldata _extra) external view returns (bytes memory) {
        (address _resolver, address _token, bytes memory _extradata) = abi.decode(_extra[8:], (address, address, bytes));
        function(bytes memory, bytes memory) external view returns(address) getAddr;
        uint32 _sel = uint32(bytes4(_extra[:4]));
        assembly {
            getAddr.selector := _sel
            getAddr.address := _resolver
        }
        try getAddr(_result, _extradata) returns (address _owner) {
            return iERC20(_token).getBalance(_owner);
        } catch Error(string memory err) {
            return string.concat("ERC20-CCIP:", err).toError();
        } catch Panic(uint256 errCode) {
            return string.concat("ERC20-CCIP:Panic ", errCode.uintToString()).toError();
        } catch (bytes memory _lookup) {
            // recursive CCIP not supported
            revert CallbackFailed(_lookup);
        }

        /*
            function(address) external returns (uint) getBal;
            _sel = uint32(bytes4(_extra[4:8]));
            assembly {
                getBal.selector := _sel
                getBal.address := _token 
            }
            try getBal(_owner) returns (uint _bal) {
                _owner = owner_;
            } catch Error(string memory err) {
                return string.concat("CCIP:", err).toError();
            } catch Panic(uint256 errCode) {
                return string.concat("CCIP:Panic ", errCode.uintToString()).toError();
            } catch (bytes memory _lookup) {
                // not recursive
                revert CallbackFailed(_lookup);
                // will revert as CCIP lookup
                //return iNotAPI(this).CCIPLookup(_lookup, _extra);
            }
            (bool ok, bytes memory _out) = _resolver.staticcall(abi.encodePacked(bytes4(_extra[:4]), _res, _orgExtra));
            if (!ok) {
                if (_out.length == 0) revert CallbackFailed();
                assembly {
                    revert(add(32, _out), mload(_out))
                }
            }
            //address _addr = abi.decode(_out, (address));
            (ok, _out) = _token.staticcall(abi.encodePacked(bytes4(_extra[4:8]), _out));
            if (!ok) {
                if (_out.length == 0) revert CallbackFailed();
                assembly {
                    revert(add(32, _out), mload(_out))
                }
            } 
            //if()
            } catch Error(string memory err) {
                return string.concat("CCIP:", err).toError();
            } catch Panic(uint256 errCode) {
                return string.concat("CCIP:Panic ", errCode.uintToString()).toError();
            } catch (bytes memory _lookup) {
                // will revert as CCIP lookup
                //return iNotAPI(this).CCIPLookup(_lookup, _extra);
            }
        */
    }

    function __callback2(bytes calldata _res, bytes calldata _extra) external view returns (bytes memory _output) {}

    function CCIPLookup(bytes4 _selector, address _contract, bytes calldata _lookup)
        external
        view
        returns (bytes memory output)
    {
        //error OffchainLookup(address _to, string[] _gateways, bytes _data, bytes4 _callbackFunction, bytes _extra);
        if (bytes4(_lookup[:4]) != iENSIP10.OffchainLookup.selector) {
            return "ERC20:Invalid CCIP Data".toError();
        }
        (address _to, string[] memory _gateways, bytes memory _data, bytes4 _callbackFunction, bytes memory _extra) =
            abi.decode(_lookup[4:], (address, string[], bytes, bytes4, bytes));
        _extra = abi.encodePacked(_callbackFunction, _selector, abi.encode(_contract, _to, _extra));
        revert iENSIP10.OffchainLookup(address(this), _gateways, _data, iNotAPI.__callback1.selector, _extra);
    }

    function resolve(bytes calldata name, bytes calldata request) external view returns (bytes memory output) {
        uint256 level;
        uint256 ptr;
        uint256 len;
        bytes[] memory _labels = new bytes[](7);
        while (name[ptr] > 0x0) {
            len = uint8(bytes1(name[ptr:++ptr]));
            _labels[level++] = name[ptr:ptr += len];
        }
        if (level < 3) {
            // notapi.eth
        }
        require(bytes4(request[:4]) == iResolver.contenthash.selector, "Only Contenthash Supported");
        bytes32 _type = bytes32(_labels[0]);
        if (_type == bytes32(bytes("erc20")) || _type == bytes32(bytes("token"))) {
            _type = bytes32(_labels[1]);
            iERC20 erc20;
            if (_labels[1].isAddr()) {
                // address
                erc20 = iERC20(_labels[1].stringToAddress());
            } else if (TokenMap[_type] != address(0)) {
                // symbol
                erc20 = iERC20(TokenMap[_type]);
            } else {
                return "ERC20:Invalid Token".toError();
            }
            if (address(erc20).checkInterface(0x80ac58cd) || address(erc20).checkInterface(0xd9b67a26)) {
                return "ERC20:Invalid Contract".toError();
            } else if (address(erc20).checkSupply() == 0) {
                return "ERC20:Zero Supply".toError();
            }
            _type = bytes32(_labels[2]);
            if (FunctionMap[bytes32(_labels[2])] == 0x0) {
                return "ERC20:Invalid Function".toError();
            }
            bytes4 _fun = FunctionMap[bytes32(_labels[2])];
            if (_fun == iERC20.balanceOf.selector) {
                address _owner;
                if (level == 6) {
                    // erc20.dai.balanceof.<0xaddress>.notapi.eth
                    if (!_labels[3].isAddr()) return "ERC20:Invalid Owner Address".toError();
                    _owner = _labels[3].stringToAddress();
                } else if (level > 6) {
                    // erc20.dai.balanceof...domain.<eth>.notapi.eth
                    bytes32 _node = bytes32(request[4:]); // 1st try with full node hash
                    address _resolver = ENS.resolver(_node);
                    bytes memory _encodedName;
                    if (_resolver == address(0)) {
                        ptr = level - 3;
                        _node = keccak256(abi.encodePacked(bytes32(0), keccak256(_labels[ptr])));
                        _encodedName = abi.encodePacked(uint8(_labels[ptr].length), _labels[ptr], hex"00");
                        while (ptr > 3) {
                            _node = keccak256(abi.encodePacked(_node, keccak256(_labels[--ptr])));
                            _encodedName = abi.encodePacked(uint8(_labels[ptr].length), _labels[ptr], _encodedName);
                            if (ENS.resolver(_node) != address(0)) {
                                _resolver = ENS.resolver(_node);
                            }
                        }
                    }
                    if (_resolver == address(0)) {
                        return "ERC20:ENS Resolver Not Set".toError();
                    } else if (_resolver.checkInterface(iResolver.addr.selector)) {
                        _owner = iResolver(_resolver).addr(_node);
                    } else if (_resolver.checkInterface(iENSIP10.resolve.selector)) {
                        try iENSIP10(_resolver).resolve(
                            _encodedName, abi.encodeWithSelector(iResolver.addr.selector, _node)
                        ) returns (bytes memory _data) {
                            _owner = abi.decode(_data, (address));
                        } catch Error(string memory err) {
                            return string.concat("ERC20:", err).toError();
                        } catch Panic(uint256 errCode) {
                            return string.concat("ERC20:Panic ", errCode.uintToString()).toError();
                        } catch (bytes memory _lookup) {
                            // will revert as CCIP lookup
                            return iNotAPI(this).CCIPLookup(iERC20.balanceOf.selector, address(erc20), _lookup);
                        }
                    } else {
                        "ERC20:Invalid ENS Domain".toError();
                    }
                } else {
                    return "ERC20:Invalid Owner".toError();
                }
                if (_owner == address(0)) {
                    return "ERC20:Owner Address Not Set".toError();
                }
                return erc20.getBalance(_owner);
            } else if (_fun == iERC20.allowance.selector) {
                if (!_labels[3].isAddr()) {
                    return "ERC20:Invalid Owner".toError();
                }
                if (!_labels[4].isAddr()) {
                    return "ERC20:Invalid Spender".toError();
                }
                return erc20.getAllowance(_labels[3].stringToAddress(), _labels[4].stringToAddress());
            }
            return erc20.getInfo();
        }
    }

    /// @dev : utils functions

    function transferToken(address _token) external {
        iERC20(_token).transfer(owner, iERC20(_token).balanceOf(address(this)));
    }

    function transferEther() external {
        payable(owner).transfer(address(this).balance);
    }

    function transferOwnership(address _newOwner) external {
        require(msg.sender == owner, "Only Owner");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    function addInterface(bytes4 _interface, bool _set) external {
        require(msg.sender == owner, "Only Owner");
        supportsInterface[_interface] = _set;
    }

    /// @dev : token symbol must be lowercase
    /// @dev : set _token to address(0) to remove

    function setToken(address _token, string calldata _symbol) external {
        require(msg.sender == owner, "Only Owner");
        TokenMap[bytes32(bytes(_symbol))] = _token;
    }

    function setTokenBatch(address[] calldata _token, string[] calldata _symbol) external {
        require(msg.sender == owner, "Only Owner");
        require(_token.length == _symbol.length, "Length Mismatch");
        for (uint256 i = 0; i < _token.length; i++) {
            TokenMap[bytes32(bytes(_symbol[i]))] = _token[i];
        }
    }

    function setFunction(bytes4 _selector, string calldata _func) external {
        require(msg.sender == owner, "Only Owner");
        FunctionMap[bytes32(bytes(_func))] = _selector;
    }
    /*
    function setFunctionBatch(bytes4[] calldata _selector, string[] calldata _func)  external {
        require (msg.sender == owner, "Only Owner");
        require (_selector.length == _func.length, "Length Mismatch");
        for(uint i=0; i < _selector.length; i++){
            FunctionMap[bytes32(bytes(_func[i]))] = _selector[i];
        }
    }
    */

    receive() external payable {
        revert();
    }
}
