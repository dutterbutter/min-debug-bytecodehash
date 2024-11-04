// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {TestExt, StdUtils} from "forge-zksync-std/TestExt.sol";

contract CounterTest is Test, TestExt {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
        // test using StdUtils
        bytes32 bytecodeHash = StdUtils.zkGetBytecodeHash(
            type(Counter).creationCode
        );
        console.logBytes32(bytecodeHash);
        counter.setNumber(0);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
