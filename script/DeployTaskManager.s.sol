// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {TaskManager} from "../src/TaskManager.sol";

contract DeployTaskManager is Script {
    function run() external returns (TaskManager) {
        string memory deployerStr = vm.envString("DEPLOYER"); // Fetch as string
        address deployer = vm.parseAddress(deployerStr); // Convert to address

        vm.startBroadcast(deployer);
        TaskManager taskManager = new TaskManager(deployer); // Pass correct address
        vm.stopBroadcast();

        return taskManager;
    }
}
