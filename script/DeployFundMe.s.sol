// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig, NetworkConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // Before "startBroadcast" -> not a real tx
        HelperConfig config = new HelperConfig();
        address ethUsdPriceFeed = config.activeNetworkConfig();

        // After "startBroadcast" -> real tx
        vm.startBroadcast();
        // Mock contract
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();

        return fundMe;
    }
}
