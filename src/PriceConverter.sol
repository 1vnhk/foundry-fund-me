// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error PriceConverter__InvalidPrice();

library PriceConverter {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        if (price <= 0) {
            revert PriceConverter__InvalidPrice();
        }
        return uint256(price) * (10 ** (18 - priceFeed.decimals()));
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / (10 ** 18);

        return ethAmountInUsd;
    }

    function getVersion(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        return priceFeed.version();
    }
}
