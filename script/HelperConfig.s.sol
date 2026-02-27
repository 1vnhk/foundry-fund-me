// SPDX-License-Identifier: MIT

// 1. Deploy mocks when we're on local anvil chain
// 2. Keep track of contract addresses across different chains
// Sepolia ETH/USD address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
// Mainnet ETH/USD

pragma solidity ^0.8.33;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

struct NetworkConfig {
    address priceFeed; // ETH/USD price feed address
}

contract HelperConfig is Script {
    // If on local anvil - deploy mock contracts
    // Otherwise, use the existing address from the live chain
    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory config = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return config;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory config = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return config;
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        // 1. deploy the mocks
        // 2. return the mock addresses

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(8, 2000e8);
        vm.stopBroadcast();

        NetworkConfig memory config = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return config;
    }
}
