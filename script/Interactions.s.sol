// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 1 ether;

    function run() external {
        address _contract = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        vm.startBroadcast();
        fundFundMe(payable(_contract));
        vm.stopBroadcast();
    }

    function fundFundMe(address payable _contract) public {
        FundMe(_contract).fund{value: SEND_VALUE}();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }
}

contract WithdrawFundMe is Script {
    function run() external {
        address _contract = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        vm.startBroadcast();
        withdrawFundMe(payable(_contract));
        vm.stopBroadcast();
    }

    function withdrawFundMe(address payable _contract) public {
        FundMe(_contract).withdraw();
    }
}
