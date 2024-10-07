// SPDX-License-Identifier: WTFPL.ETH
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Utils} from "../src/Utils.sol";

contract UtilsTest is Test {
    using Utils for *;

    function testHexStringToBytes() public {
        assertEq(
            bytes(hex"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"),
            bytes("ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff").hexStringToBytes()
        );
        assertEq(
            bytes(hex"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"),
            bytes("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff").hexStringToBytes()
        );
        assertEq(
            bytes(hex"0000000000000000000000000000000000000000000000000000000000000000"),
            bytes("0x0000000000000000000000000000000000000000000000000000000000000000").hexStringToBytes()
        );
    }

    function testBytesToHexString() public {
        assertEq(
            string("ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"),
            hex"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff".bytesToHexString()
        );
        assertEq(
            string("0000000000000000000000000000000000000000000000000000000000000000"),
            hex"0000000000000000000000000000000000000000000000000000000000000000".bytesToHexString()
        );
    }

    function testStringToAddress() public {
        assertEq(address(0), string("0x0000000000000000000000000000000000000000").stringToAddress());
        assertEq(
            address(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF),
            string("0xffffffffffffffffffffffffffffffffffffffff").stringToAddress()
        );
        assertEq(
            address(0x7B0Cc5DD236EEA79C8739468BB56Ed5e147c8b06),
            string("0x7b0cc5dd236eea79c8739468bb56ed5e147c8b06").stringToAddress()
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
        assertEq("0.001%", uint256(1234).percent1e8());
        assertEq("0.012%", uint256(12345).percent1e8());
        assertEq("0.123%", uint256(123456).percent1e8());
        assertEq("1.234%", uint256(1234567).percent1e8());
        assertEq("12.345%", uint256(12345678).percent1e8());
        assertEq("0.00%", uint256(999).percent1e8());
        assertEq("0.999%", uint256(999999).percent1e8());
        assertEq("9.999%", uint256(9999999).percent1e8());
        assertEq("1.000%", uint256(1000000).percent1e8());
        assertEq("10.000%", uint256(10000000).percent1e8());
        assertEq("100%", uint256(100000000).percent1e8());
    }

    function testIdToUint() public {
        (bool ok, uint256 num) = bytes("id123456").idToUint();
        assertTrue(ok);
        assertEq(uint256(123456), num);
        (ok, num) = bytes("identity").idToUint();
        assertFalse(ok);
        assertEq(type(uint256).max, num);
        (ok, num) = bytes("id001").idToUint();
        assertTrue(ok);
        assertEq(uint256(1), num);
    }
}
