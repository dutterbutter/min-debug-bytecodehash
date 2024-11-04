// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";
import {Create2Factory} from "era-contracts/system-contracts/contracts/Create2Factory.sol";
import {L2ContractHelper} from "era-contracts/l2-contracts/contracts/L2ContractHelper.sol";

contract CounterScript is Script {
    Counter public counter;
    Create2Factory public create2Factory =
        Create2Factory(0x0000000000000000000000000000000000010000);

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        bytes32 salt = keccak256("1234");
        bytes memory constructorData = abi.encode();

        // Get the bytecode hash of the Counter contract
        bytes32 bytecodeHash = zkGetBytecodeHash(type(Counter).creationCode);

        // Compute the expected CREATE2 address
        address expectedAddress = L2ContractHelper.computeCreate2Address(
            address(this),
            salt,
            bytecodeHash,
            keccak256(constructorData)
        );

        console.log("Expected Address:", expectedAddress);

        address deployedAddress = create2Factory.create2(
            salt,
            bytecodeHash,
            abi.encode()
        );

        console.log("Expected Address:", expectedAddress);
        console.log("Deployed Address:", deployedAddress);

        require(
            expectedAddress == deployedAddress,
            "Computed and deployed addresses do not match"
        );

        vm.stopBroadcast();
    }

    function zkGetBytecodeHash(
        bytes memory code
    ) internal pure returns (bytes32) {
        console.logBytes(code);
        require(code.length >= 100, "Data must be at least 100 bytes");

        bytes32 result;
        // Load 32 bytes starting from the 68th byte
        assembly {
            result := mload(add(code, 68)) // 68 + 32 = 100
        }
        return result;
    }
}
