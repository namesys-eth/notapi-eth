// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "./Interface.sol";
import "./Utils.sol";
import "./ERC20Data.sol";

contract NotAPI is iERC173, iERC165 {
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

    function resolve(bytes calldata name, bytes calldata request) external view returns (bytes memory output) {
        uint256 level;
        uint256 n;
        uint256 len;
        bytes[] memory _labels = new bytes[](7);
        while (name[n] > 0x0) {
            len = uint8(bytes1(name[n:++n]));
            _labels[level++] = name[n:n += len];
        }
        if (level < 3) {
            // notapi.eth
        }
        require(bytes4(request[:4]) == iResolver.contenthash.selector, "Only Contenthash Supported");
        bytes32 _type = bytes32(_labels[0]);
        if (_type == bytes32(bytes("erc20")) || _type == bytes32(bytes("token"))) {
            _type = bytes32(_labels[1]);
            iERC20 erc20;
            if (_labels[1].length == 42) {
                // address
                erc20 = iERC20(_labels[1].stringToAddress());
            } else if (TokenMap[_type] != address(0)) {
                // symbol
                erc20 = iERC20(TokenMap[_type]);
            } else {
                return "ERC20:Invalid Format".toError();
            }
            if (address(erc20).checkInterface(0x80ac58cd) || address(erc20).checkInterface(0xd9b67a26)) {
                return "ERC20:Invalid Contract".toError();
            } else if (erc20.checkSupply() == 0) {
                return "ERC20:Zero Supply".toError();
            }
            _type = bytes32(_labels[2]);
            if (FunctionMap[_type] != 0x0) {
                bytes4 _fun = FunctionMap[_type];
                if (_fun == iERC20.balanceOf.selector) {
                    address _owner; 
                    if (_labels[3].isAddr()) {
                        _owner = _labels[3].stringToAddress();
                    } else if (level == 6 && bytes32(_labels[4]) == bytes32(bytes("eth"))) {
                        // erc20.dai.balanceof.domain.<eth>.notapi.eth
                        bytes32 _namehash = keccak256(abi.encodePacked(bytes32(0), keccak256(_labels[4])));
                        _namehash = keccak256(abi.encodePacked(_namehash, keccak256(_labels[3])));
                        
                        _owner = _labels[3].stringToAddress();
                    } else if (level == 7 && bytes32(_labels[5]) == bytes32(bytes("eth"))) {
                        // erc20.dai.balanceof.sub.domain.<eth>.notapi.eth
                        _owner = _labels[3].stringToAddress();
                    } else {
                        return "ERC20:Invalid Owner".toError();
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
            return "ERC20:Invalid Function".toError();
        }
    }

    /// @dev : utils functions
    function transferToken(address _token, uint256 _bal) external {
        iERC20(_token).transfer(owner, _bal);
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
    /*
    function setFunction(bytes4 _selector, string calldata _func)  external {
        require (msg.sender == owner, "Only Owner");
        FunctionMap[bytes32(bytes(_func))] = _selector;
    }    
    
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
