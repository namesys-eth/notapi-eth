// SPDX-License-Identifier: WTFPL.ETH
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {LibString} from "../src/LibString.sol"; // Use LibString directly
import {Utils} from "../src/Utils.sol";

contract UtilsTest is Test {
    using LibString for *; // Use LibString for all string manipulations
    using Utils for *; // Use LibString for all string manipulations

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
            string("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"),
            hex"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff".toHexString()
        );
        assertEq(
            string("0x0000000000000000000000000000000000000000000000000000000000000000"),
            hex"0000000000000000000000000000000000000000000000000000000000000000".toHexString()
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
            address(0x7B0Cc5DD236EEA79C8739468BB56Ed5e147c8b06).toHexStringChecksummed(),
            string("0x7B0Cc5DD236EEA79C8739468BB56Ed5e147c8b06")
        );
        assertEq(
            address(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF).toHexStringChecksummed(),
            string("0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF")
        );
        assertEq(
            address(0x0000000000000000000000000000000000000000).toHexStringChecksummed(),
            string("0x0000000000000000000000000000000000000000")
        );
        assertEq(
            address(0x1234567890AbcdEF1234567890aBcdef12345678).toHexStringChecksummed(),
            string("0x1234567890AbcdEF1234567890aBcdef12345678")
        );
    }

    function testUintToString() public {
        assertEq(string("123456789"), uint256(123456789).toString());
        assertEq(string("0"), uint256(0).toString());
        assertEq(string("11111"), uint256(11111).toString());
        assertEq(string("99999"), uint256(99999).toString());
        assertEq(
            string("123456789123456789123456789123456789123456789123456789"),
            uint256(123456789123456789123456789123456789123456789123456789).toString()
        );
        assertEq(
            string("115792089237316195423570985008687907853269984665640564039457584007913129639935"),
            (type(uint256).max).toString()
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
