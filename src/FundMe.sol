// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();
error FundMe__AmountTooSmall();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MIN_USD = 5 * 10 ** 18;
    address public immutable I_OWNER;

    mapping(address => uint256) public funderToAmount;
    address[] public funders;

    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        I_OWNER = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        if (msg.value.getConversionRate(s_priceFeed) <= MIN_USD) {
            revert FundMe__AmountTooSmall();
        }
        // check min usd and revert
        // include oracle from chainlink. Build from scratch
        funders.push(msg.sender);
        funderToAmount[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            funderToAmount[funder] = 0;
        }

        funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    function priceFeedVersion() public view returns (uint256) {
        return PriceConverter.getVersion(s_priceFeed);
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        if (msg.sender != I_OWNER) {
            revert FundMe__NotOwner();
        }
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
