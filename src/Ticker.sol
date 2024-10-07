// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import "./Interface.sol";
import "./Utils.sol";
import "./Generator.sol";

abstract contract ERC173 is iERC173 {
    using Utils for *;

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
        supportsInterface[iERC173.transferOwnership.selector] = true;
        supportsInterface[iERC165.supportsInterface.selector] = true;
    }

    function setInterface(bytes4 _sig, bool _set) external onlyOwner {
        supportsInterface[_sig] = _set;
        emit InterfaceUpdate(_sig, _set);
    }
}

abstract contract Manager is ERC165 {
    using Generator for *;
    using Utils for *;

    iENS public immutable ENS = iENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
    iENSNFT public ENSNFT = iENSNFT(0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85);
    iERC20 public ENSToken = iERC20(0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85);

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
        if (featured) {
            fid = uint8(Featured.length);
            Featured.push(ticker);
        }
        Tickers[label] = Ticker(fid, _erc, _addr);
        emit TickerUpdated(_erc, _addr);
    }

    function setBatchTicker(uint16 _erc, address[] calldata _addr, string[] calldata labels) external onlyOwner {
        uint256 len = labels.length;
        require(len == _addr.length, "BAD_LENGTH");
        for (uint256 i = 0; i < len; i++) {
            bytes32 label = keccak256(bytes(labels[i]));
            require(Tickers[label]._erc == 0, "ACTIVE_TICKER");
            Tickers[label] = Ticker(0, _erc, _addr[i]);
            emit TickerUpdated(_erc, _addr[i]);
        }
    }

    function getBytes(bytes calldata _b, uint256 _start, uint256 _end) external pure returns (bytes memory) {
        return _b[_start:_end == 0 ? _b.length : _end];
    }

    // Get featured tokens for an address
    function getFeatured(address _addr) public view returns (bytes memory) {
        uint256 len = Featured.length;
        /**
         * ETH:[balance, address, decimals, totalSupply], DAI:[..]..
         * ENS:[balance, address, royalty, totalSupply, contractURI], ARTY:[..]..
         */
        bytes memory feat20 = abi.encodePacked('"ETH":["', (_addr.balance).uintToString(), '","","18",""]');
        bytes memory feat721 = abi.encodePacked(
            '"ENS":[',
            ENSNFT.balanceOf(_addr).uintToString(),
            ',"0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85",false,',
            //ENSNFT.totalSupply().uintToString(),
            ',""'
        );
        Ticker memory ticker;
        uint256 balance;
        for (uint256 i = 1; i < len; i++) {
            ticker = Tickers[keccak256(bytes(Featured[i]))];
            balance = iERC20(ticker._addr).balanceOf(_addr);
            if (balance > 0) {
                if (ticker._erc == 20) {
                    feat20 = abi.encodePacked(feat20, ",", getFeatured20(iERC20(ticker._addr), balance));
                } else if (ticker._erc == 721) {
                    feat721 = abi.encodePacked(feat721, ",", getFeatured721(iERC721(ticker._addr), balance));
                }
            }
        }

        return abi.encodePacked('"erc20":{', feat20, '},"erc721":{', feat721, "}");
    }

    function getFeatured20(iERC20 erc20, uint256 balance) public view returns (bytes memory) {
        return abi.encodePacked(
            '"',
            erc20.symbol(),
            '":["',
            balance.uintToString(),
            '","',
            address(erc20).toChecksumAddress(),
            '","',
            erc20.decimals().uintToString(),
            '","',
            erc20.totalSupply().uintToString(),
            '"]'
        );
    }

    function getFeatured721(iERC721 erc721, uint256 balance) public view returns (bytes memory) {
        return abi.encodePacked(
            '"',
            erc721.symbol(),
            '":["',
            balance.uintToString(),
            '","',
            address(erc721).toChecksumAddress(),
            '","',
            iERC165(address(erc721)).supportsInterface(iERC2981.royaltyInfo.selector) ? "true" : "false",
            '","',
            erc721.totalSupply().uintToString(),
            '","',
            iERC7572(address(erc721)).contractURI(), // TODO: use try catch for this
            '"]'
        );
    }
}
