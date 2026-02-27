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

    mapping(address => uint256) private s_funderToAmount;
    address[] private s_funders;

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
        s_funders.push(msg.sender);
        s_funderToAmount[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_funderToAmount[funder] = 0;
        }

        s_funders = new address[](0);

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

    // view / pure functions
    function getFunderToAmount(address funder) external view returns (uint256) {
        return s_funderToAmount[funder];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }
}
