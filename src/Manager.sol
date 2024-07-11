// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "./Interface.sol";
import "./Utils.sol";
import "./Generator.sol";

abstract contract ERC173 is iERC173 {
    address public owner;

    error OnlyOwner();

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, OnlyOwner());
        _;
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        emit OwnershipTransferred(owner, _newOwner);
        owner == _newOwner;
    }
}

abstract contract ERC165 is iERC165, ERC173 {
    mapping(bytes4 => bool) public supportsInterface;

    event InterfaceUpdate(bytes4 _sig, bool _set);

    constructor() {
        supportsInterface[iERC173.owner.selector] = true;
        supportsInterface[iERC165.supportsInterface.selector] = true;
    }

    function setInterface(bytes4 _sig, bool _set) external onlyOwner {
        supportsInterface[_sig] = _set;
        emit InterfaceUpdate(_sig, _set);
    }
}

abstract contract Manager is ERC165 {
    //using Utils for *;
    //using JSON for *;

    //function Featured(uint) public view returns(string memory);
    struct Ticker {
        uint8 _ft;
        uint16 _erc;
        address _addr;
    }

    mapping(bytes32 => Ticker) public Tickers;
    string[] public Featured;
    bytes32 immutable ENSRoot = keccak256(abi.encodePacked(bytes32(0), keccak256("eth")));

    //bytes32 immutable NOTAPIRoot = keccak256(abi.encodePacked(ENSRoot, keccak256("notapi")));

    constructor() {
        
        string memory _sub = "eth";
        address _token = address(type(uint160).max);
        bytes32 label = keccak256(bytes(_sub));
        Tickers[label] = Ticker(0, 20, _token);
        emit TickerUpdated(20, _token);
        Featured.push(_sub);

        _sub = "dai";
        _token = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        label = keccak256(bytes(_sub));
        Tickers[label] = Ticker(1, 20, _token);
        emit TickerUpdated(20, _token);
        Featured.push(_sub);

        _sub = "usdc";
        _token = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        label = keccak256(bytes(_sub));
        Tickers[label] = Ticker(2, 20, _token);
        emit TickerUpdated(20, _token);
        Featured.push(_sub);
    }

    event TickerUpdated(uint16 indexed _erc, address indexed _addr);

    function setTicker(uint16 _erc, bool featured, address _addr, string calldata ticker) external onlyOwner {
        uint8 fid = 0;
        bytes32 label = keccak256(bytes(ticker));
        require(Tickers[label]._erc == 0, "ACTIVE_TICKER");
        if(featured){
            fid = uint8(Featured.length);
            Featured.push(ticker);
        }
        Tickers[label] = Ticker(fid, _erc, _addr);
        emit TickerUpdated(_erc, _addr);
    }

    function setBatchTicker(uint16 _erc, address[] calldata _addr, string[] calldata sub) external onlyOwner {
        uint256 len = sub.length;
        require(len == _addr.length, "BAD_LENGTH");
        for (uint256 i = 0; i < len; i++) {
            bytes32 label = keccak256(bytes(sub[i]));
            require(Tickers[label]._erc == 0, "ACTIVE_TICKER");
            Tickers[label] = Ticker(0, _erc, _addr[i]);
            emit TickerUpdated(_erc, _addr[i]);
        }
    }
    
    function getBytes(bytes calldata _b, uint256 _start, uint256 _end) public pure returns (bytes memory) {
        return _b[_start:_end == 0 ? _b.length : _end];
    }
}
