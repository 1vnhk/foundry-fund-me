// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 100 ether;
    uint256 constant SEND_VALUE = 1 ether;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();

        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUsdIsFive() public view {
        assertEq(fundMe.MIN_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.I_OWNER(), msg.sender);
    }

    function testFeedPriceVersionIsAccurate() public view {
        uint256 version = fundMe.priceFeedVersion();
        if (block.chainid == 11155111) {
            assertEq(version, 4);
        } else if (block.chainid == 1) {
            assertEq(version, 6);
        }
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testFundUpdatesBalances() public funded {
        assertEq(fundMe.getFunderToAmount(USER), 1 ether);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        assertEq(fundMe.getFunder(0), USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }
}
