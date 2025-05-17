// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {NFTFactory} from "../src/NFTFactory.sol";
import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
contract Deploy is Script {
    function run() public {
        vm.startBroadcast();
        NFTFactory factory = new NFTFactory(1000000000000);
        console.log("NFTFactory deployed at:", address(factory));
        vm.stopBroadcast();
    }
}