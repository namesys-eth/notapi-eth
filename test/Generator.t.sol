// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;

import {Test, console2} from "forge-std/Test.sol";
import {Generator} from "../src/Generator.sol";
import "./Format.sol";

contract GeneratorTest is Test {
    using Generator for *;

    Format _format = new Format();

    function testErrorGenerator() public {
        bytes memory result = "Hello World".toError();
        assertEq(
            result,
            hex"e301018004004f7b226f6b223a66616c73652c2274696d65223a313731373238313430372c22626c6f636b223a32303030303030302c226572726f72223a2248656c6c6f20576f726c64222c2264617461223a22227d"
        );
        string memory _exp = '{"ok":false,"time":1717281407,"block":20000000,"error":"Hello World","data":""}';
        assertEq(_exp, string(_format.getBytes(result, 7, result.length)));
    }
}
