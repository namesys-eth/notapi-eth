// SPDX-License-Identifier: WTFPL.ETH
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Utils} from "../src/Utils.sol";

contract UtilsTest is Test {
    using Utils for *;

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

    function testStringToAddress() public {
        assertEq(address(0), bytes(string("0x0000000000000000000000000000000000000000")).stringToAddress());
        assertEq(
            address(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF),
            bytes(string("0xffffffffffffffffffffffffffffffffffffffff")).stringToAddress()
        );
        assertEq(
            address(0x7B0Cc5DD236EEA79C8739468BB56Ed5e147c8b06),
            bytes(string("0x7b0cc5dd236eea79c8739468bb56ed5e147c8b06")).stringToAddress()
        );
    }

    function testChecksumAddress() public {
        assertEq(
            address(0x7B0Cc5DD236EEA79C8739468BB56Ed5e147c8b06).toChecksumAddress(),
            string("0x7B0Cc5DD236EEA79C8739468BB56Ed5e147c8b06")
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

    function testPercent() public {
        assertEq("0.001%", uint(1234).percentX1e8());
        assertEq("0.012%", uint(12345).percentX1e8());
        assertEq("0.123%", uint(123456).percentX1e8());
        assertEq("1.234%", uint(1234567).percentX1e8());
        assertEq("12.345%", uint(12345678).percentX1e8());
        assertEq("0.00%", uint(999).percentX1e8());
        assertEq("0.999%", uint(999999).percentX1e8());
        assertEq("9.999%", uint(9999999).percentX1e8());
        assertEq("1.000%", uint(1000000).percentX1e8());
        assertEq("10.000%", uint(10000000).percentX1e8());
        assertEq("100%", uint(100000000).percentX1e8());
    }

    function testIdToUint() public {
        (bool ok, uint num) = bytes("id123456").idToUint(); 
        assertTrue(ok);
        assertEq(uint(123456), num);
        (ok, num) = bytes("identity").idToUint(); 
        assertFalse(ok);
        assertEq(type(uint).max, num);
        (ok, num) = bytes("id001").idToUint(); 
        assertTrue(ok);
        assertEq(uint(1), num);
    }
}
