pragma solidity >0.8.0 <0.9.0;

import {Test, console2} from "forge-std/Test.sol";
import "../src/Interface.sol";
import "../src/NotAPI.sol";
import "./Format.sol";

contract ERC721Test is Test, Format {
    iERC721 public exampleNFT = iERC721(0x8a90CAb2b38dba80c64b7734e58Ee1dB38B8992e); // Replace with actual ERC721 contract address
    NotAPI notapi = new NotAPI();

    function testERC721Info() public {
        bytes[] memory _name = new bytes[](3);
        _name[0] = "exampleNFT"; // Replace with actual NFT name
        _name[1] = "notapi";
        _name[2] = "eth";
        (bytes32 _namehash, bytes memory _encoded) = Encode(_name);
        bytes memory _result =
            notapi.resolve(_encoded, abi.encodeWithSelector(iResolver.contenthash.selector, _namehash));
        
        // Expected output should be adjusted based on the actual ERC721 contract
        string memory _exp =
            '{"ok":true,"time":1717281407,"block":20000000,"result":{"contract":"0x8a90CAb2b38dba80c64b7734e58Ee1dB38B8992e","name":"Example NFT","symbol":"ENFT","supply":"10000"}}'; // Adjust expected output
        assertEq(_exp, string(this.getBytes(_result, 8, _result.length)));
        assertEq(
            _result,
            hex"e30101800400d7017b226f6b223a747275652c2274696d65223a313731373238313430372c22626c6f636b223a32303030303030302c22726573756c74223a7b22636f6e7472616374223a22307836423137353437344538393039344334344461393862393534456564654143343935323731643046222c22646563696d616c73223a31382c22657263223a32302c226e616d65223a2244616920537461626c65636f696e222c22737570706c79223a2233323731373131363536343135323430383236373032313530323335222c2273796d626f6c223a22444149227d7d"
        );
    }

    function testERC721BalanceInfo() public {
        bytes[] memory _name = new bytes[](3);
        _name[0] = "exampleNFT"; // Replace with actual NFT name
        _name[1] = "notapi";
        _name[2] = "eth";
        (bytes32 _namehash, bytes memory _encoded) = Encode(_name);
        bytes memory _result =
            notapi.resolve(_encoded, abi.encodeWithSelector(iResolver.contenthash.selector, _namehash));
        
        // Expected output should be adjusted based on the actual ERC721 contract
        string memory _exp =
            '{"ok":true,"time":1717281407,"block":20000000,"result":{"contract":"0x8a90CAb2b38dba80c64b7734e58Ee1dB38B8992e","name":"Example NFT","symbol":"ENFT","supply":"10000"}}'; // Adjust expected output
        assertEq(_exp, string(this.getBytes(_result, 8, _result.length)));
        assertEq(
            _result,
            hex"e30101800400d7017b226f6b223a747275652c2274696d65223a313731373238313430372c22626c6f636b223a32303030303030302c22726573756c74223a7b22636f6e7472616374223a22307836423137353437344538393039344334344461393862393534456564654143343935323731643046222c22646563696d616c73223a31382c22657263223a32302c226e616d65223a2244616920537461626c65636f696e222c22737570706c79223a2233323731373131363536343135323430383236373032313530323335222c2273796d626f6c223a22444149227d7d"
        );
    }

    function testERC721Ownership() public {
        uint256 tokenId = 1; // Replace with a valid token ID
        address expectedOwner = address(this); // Replace with the expected owner address

        // Check ownership
        assertEq(exampleNFT.ownerOf(tokenId), expectedOwner, "Owner should match expected address");
    }

    function testERC721Balance() public {
        address owner = address(this); // Replace with the address you want to check
        uint256 balance = exampleNFT.balanceOf(owner);

        // Check balance
        assertEq(balance, 1, "Balance should match expected value"); // Replace with expected balance
    }

    function testERC721TokenURI() public {
        uint256 tokenId = 1; // Replace with a valid token ID
        string memory expectedURI = "https://example.com/token/1"; // Replace with expected URI

        // Check token URI
        assertEq(exampleNFT.tokenURI(tokenId), expectedURI, "Token URI should match expected value");
    }
}