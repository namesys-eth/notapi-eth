// SPDX-License-Identifier: WTFPL.ETH
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Utils} from "../src/Utils.sol";

contract UtilsTest is Test {
    using Utils for *;

    function testErrorJson() public {
        assertEq(
            "Hello World".toError(),
            hex"e30101800400437b226572726f72223a2248656c6c6f20576f726c64222c2274696d657374616d70223a2231373031343531323233222c22626c6f636b223a223138363933303134227d"
        );
    }

    function testHexStringToBytes() public {
        assertEq(
            bytes(hex"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"),
            bytes(string("ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff")).hexStringToBytes()
        );
        assertEq(
            bytes(hex"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"),
            bytes(string("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff")).hexStringToBytes()
        );
        assertEq(
            bytes(hex"0000000000000000000000000000000000000000000000000000000000000000"),
            bytes(string("0x0000000000000000000000000000000000000000000000000000000000000000")).hexStringToBytes()
        );
    }

    function testBytesToHexString() public {
        assertEq(
            string("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"),
            hex"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff".bytesToHexString()
        );
        assertEq(
            string("0x0000000000000000000000000000000000000000000000000000000000000000"),
            hex"0000000000000000000000000000000000000000000000000000000000000000".bytesToHexString()
        );
    }

    function testStringToUint() public {
        assertEq(123456789, bytes("123456789").stringToUint());
        assertEq(0, bytes("0").stringToUint());
        assertEq(11111, bytes("11111").stringToUint());
        assertEq(99999, bytes("99999").stringToUint());
        assertEq(
            123456789123456789123456789123456789123456789123456789,
            bytes("123456789123456789123456789123456789123456789123456789").stringToUint()
        );
        assertEq(
            type(uint256).max,
            bytes("115792089237316195423570985008687907853269984665640564039457584007913129639935").stringToUint()
        );
    }

    function testUintToString() public {
        assertEq(string("123456789"), 123456789.uintToString());
        assertEq(string("0"), 0.uintToString());
        assertEq(string("11111"), 11111.uintToString());
        assertEq(string("99999"), 99999.uintToString());
        assertEq(
            string("123456789123456789123456789123456789123456789123456789"),
            123456789123456789123456789123456789123456789123456789.uintToString()
        );
        assertEq(
            string("115792089237316195423570985008687907853269984665640564039457584007913129639935"),
            (type(uint256).max).uintToString()
        );
    }

    function testStringToAddress() public {
        assertEq(address(0), bytes(string("0x0000000000000000000000000000000000000000")).stringToAddress());
        assertEq(
            address(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF),
            bytes(string("0xffffffffffffffffffffffffffffffffffffffff")).stringToAddress()
        );
    }
}
