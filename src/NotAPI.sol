pragma solidity >0.8.0 <0.9.0;

import "./Interface.sol";
import "./Utils.sol";
import "./TokenData.sol";

contract NotAPI {
    using Utils for *;
    using TokenData for iERC20;

    address public owner;
    /// @dev : ERC165 interface check
    mapping(bytes4 => bool) supportsInterface;
    /// @dev : Map token symbol to token address
    mapping(bytes32 => address) public TokenMap;
    /// @dev : Map function name to bytes4 selector
    mapping(bytes32 => bytes4) public FunctionMap;

    constructor() {
        supportsInterface[iERC165.supportsInterface.selector] = true;
        supportsInterface[iENSIP10.resolve.selector] = true;
        //supportsInterface[type(iERC173).interfaceId] = true;

        //FunctionMap["name"] = iERC20.name.selector;
        //FunctionMap["symbol"] = iERC20.symbol.selector;
        FunctionMap["balanceof"] = iERC20.balanceOf.selector;
        FunctionMap["allowance"] = iERC20.allowance.selector;
        //FunctionMap["totalsupply"] = iERC20.totalSupply.selector;
        //FunctionMap["decimals"] = iERC20.decimals.selector;

        FunctionMap["tokenuri"] = iERC721.tokenURI.selector;
        FunctionMap["ownerof"] = iERC721.ownerOf.selector;
        FunctionMap["getapproved"] = iERC721.getApproved.selector;
        FunctionMap["isapprovedforall"] = iERC721.isApprovedForAll.selector;
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
                return "Invalid Format".toError();
            }
            if (checkInterface(address(erc20), 0x80ac58cd) || checkInterface(address(erc20), 0xd9b67a26)) {
                return "Invalid ERC20 Contract".toError();
            } else if (erc20.checkSupply() == 0) {
                return "Zero Supply".toError();
            }
            _type = bytes32(_labels[2]);
            if (FunctionMap[_type] != 0x0) {
                bytes4 _fun = FunctionMap[_type];
                if (_fun == iERC20.balanceOf.selector) {
                    // erc20.dai.balanceof.<___>.notapi.eth
                    if (_labels[3].length != 42 || _labels[3][0] != bytes1("0") || _labels[3][1] != bytes1("x")) {
                        return "Invalid Balance Call".toError();
                    }
                    return erc20.balance(_labels[3].stringToAddress());
                } else if (_fun == iERC20.allowance.selector) {
                    if (_labels[3].length != 42 || _labels[3][0] != bytes1("0") || _labels[3][1] != bytes1("x")) {
                        return "Invalid Owner Address".toError();
                    }
                    if (_labels[4].length != 42 || _labels[4][0] != bytes1("0") || _labels[4][1] != bytes1("x")) {
                        return "Invalid Spender Address".toError();
                    }
                    return erc20.allowed(_labels[3].stringToAddress(), _labels[4].stringToAddress());
                } else {
                    return erc20.info();
                }
            } else {
                return erc20.info();
            }
            /*if(
                _type == bytes32(bytes("notapi")) || 
                _type == bytes32(bytes("totalsupply")) || 
                _type == bytes32(bytes("name")) || 
                _type == bytes32(bytes("symbol")) || 
                _type == bytes32(bytes("decimal"))
            ){
                return erc20.info();
            }*/
        }
    }

    function checkInterface(address _contract, bytes4 _interface) internal view returns (bool) {
        try iERC165(_contract).supportsInterface{gas: 66666}(_interface) returns (bool ok) {
            return ok;
        } catch {
            return false;
        }
    }
}
