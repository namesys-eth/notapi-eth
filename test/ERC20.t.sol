// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import {Test, console2} from "forge-std/Test.sol";
import "../src/Utils.sol";
import "../src/Interface.sol";
import "../src/NotAPI.sol";
import "./Format.sol";

//0x6c6Bc977E13Df9b0de53b251522280BB72383700

contract ERC20Test is Test, Format {
    iERC20 public DAI = iERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    NotAPI notapi = new NotAPI();

    function testTickerInfo() public {
        bytes[] memory _name = new bytes[](3);
        _name[0] = "dai";
        _name[1] = "notapi";
        _name[2] = "eth";
        (bytes32 _namehash, bytes memory _encoded) = Encode(_name);
        bytes memory _result =
            notapi.resolve(_encoded, abi.encodeWithSelector(iResolver.contenthash.selector, _namehash));
        string memory _exp =
            '{"ok":true,"time":1717281407,"block":20000000,"result":{"contract":"0x6B175474E89094C44Da98b954EedeAC495271d0F","decimals":18,"erc":20,"name":"Dai Stablecoin","supply":"3271711656415240826702150235","symbol":"DAI"}}';
        assertEq(_exp, string(this.getBytes(_result, 8, _result.length)));
        assertEq(
            _result,
            hex"e30101800400d7017b226f6b223a747275652c2274696d65223a313731373238313430372c22626c6f636b223a32303030303030302c22726573756c74223a7b22636f6e7472616374223a22307836423137353437344538393039344334344461393862393534456564654143343935323731643046222c22646563696d616c73223a31382c22657263223a32302c226e616d65223a2244616920537461626c65636f696e222c22737570706c79223a2233323731373131363536343135323430383236373032313530323335222c2273796d626f6c223a22444149227d7d"
        );
    }

    function testERC20Info() public {
        bytes[] memory _name = new bytes[](3);
        _name[0] = "0x6b175474e89094c44da98b954eedeac495271d0f";
        _name[1] = "notapi";
        _name[2] = "eth";
        (bytes32 _namehash, bytes memory _encoded) = Encode(_name);
        bytes memory _result =
            notapi.resolve(_encoded, abi.encodeWithSelector(iResolver.contenthash.selector, _namehash));
        string memory _exp =
            '{"ok":true,"time":1717281407,"block":20000000,"result":{"contract":"0x6B175474E89094C44Da98b954EedeAC495271d0F","decimals":18,"erc":20,"name":"Dai Stablecoin","supply":"3271711656415240826702150235","symbol":"DAI"}}';
        assertEq(_exp, string(this.getBytes(_result, 8, _result.length)));
        assertEq(
            _result,
            hex"e30101800400d7017b226f6b223a747275652c2274696d65223a313731373238313430372c22626c6f636b223a32303030303030302c22726573756c74223a7b22636f6e7472616374223a22307836423137353437344538393039344334344461393862393534456564654143343935323731643046222c22646563696d616c73223a31382c22657263223a32302c226e616d65223a2244616920537461626c65636f696e222c22737570706c79223a2233323731373131363536343135323430383236373032313530323335222c2273796d626f6c223a22444149227d7d"
        );
    }

    function testERC20BalanceInfo() public {
        bytes[] memory _name = new bytes[](3);
        _name[0] = "vitalik";
        _name[1] = "notapi";
        _name[2] = "eth";
        (bytes32 _namehash, bytes memory _encoded) = Encode(_name);
        bytes memory _result =
            notapi.resolve(_encoded, abi.encodeWithSelector(iResolver.contenthash.selector, _namehash));
        string memory _exp =
            '{"ok":true,"time":1717281407,"block":20000000,"result":{"contract":"0x6B175474E89094C44Da98b954EedeAC495271d0F","decimals":18,"erc":20,"name":"Dai Stablecoin","supply":"3271711656415240826702150235","symbol":"DAI"}}';
        assertEq(_exp, string(this.getBytes(_result, 8, _result.length)));
        assertEq(
            _result,
            hex"e30101800400d7017b226f6b223a747275652c2274696d65223a313731373238313430372c22626c6f636b223a32303030303030302c22726573756c74223a7b22636f6e7472616374223a22307836423137353437344538393039344334344461393862393534456564654143343935323731643046222c22646563696d616c73223a31382c22657263223a32302c226e616d65223a2244616920537461626c65636f696e222c22737570706c79223a2233323731373131363536343135323430383236373032313530323335222c2273796d626f6c223a22444149227d7d"
        );
    }
}
